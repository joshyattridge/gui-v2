#
# Copyright (C) 2023 Victron Energy B.V.
# See LICENSE.txt for license information.
#
import json
import os
import sys

HEADER_TEMPLATE = '''
/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

// THIS FILE IS AUTOMATICALLY GENERATED!
// DO NOT EDIT IT MANUALLY!

#ifndef VICTRON_VENUSOS_GUI_V2_THEMEOBJECTS_H
#define VICTRON_VENUSOS_GUI_V2_THEMEOBJECTS_H

#include <QObject>
#include <QColor>
#include <QFont>
#include <QVariant>
#include <QVariantMap>

#include "theme.h"

namespace Victron {
namespace VenusOS {


class ThemeSingleton : public Theme
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Theme)
    QML_SINGLETON

    // property declarations
%s

public:
    ThemeSingleton(QObject *parent = nullptr)
        : Theme(parent)
    {
    }

    // property accessors
%s

    Q_INVOKABLE QColor statusColorValue(StatusLevel level, bool darkColor = false) const
    {
        const QVariant c = (level == Ok && darkColor) ? color_darkOk()
            : (level == Ok) ? color_ok()
            : (level == Warning && darkColor) ? color_darkWarning()
            : (level == Warning) ? color_warning()
            : (level == Critical && darkColor) ? color_darkCritical()
            : color_critical();
        return c.typeId() == QMetaType::QColor ? c.value<QColor>() : QColor(c.value<QString>());
    }
};


} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_VENUSOS_GUI_V2_THEMEOBJECTS_H

'''

def spaces_to_tabs(line):
    return line.replace('    ', '\t')

def color_to_rgba(value):
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4, 6))

def qt_value_string(type_name, value):
    if type_name == 'QColor':
        if value.startswith('#'):
            hex_color = value[1:]
            if len(hex_color) == 6:
                hex_color = 'FF' + hex_color # prefix with alpha component
            assert len(hex_color) == 8, 'Invalid color: {}'.format(hex_color)
            rgba = color_to_rgba(hex_color)
            return 'QColor({}, {}, {}, {})'.format(rgba[1], rgba[2], rgba[3], rgba[0]) # hex color is AARRGGBB format
        elif value == 'transparent':
            return 'QColor(0, 0, 0, 0)'
        else:
            raise ValueError('value {} is not a color'.format(value))
    else:
        return str(value)

class ThemeProperty:
    def __init__(self, name, json_info):
        self.name = name
        self.json_info = json_info
        self.values = {}
        self.type_name = None

    def __str__(self):
        return 'ThemeProperty(name={},values={})'.format(self.name, self.values)

    def set_value(self, value, theme_enum_value=''):
        self.values[theme_enum_value] = value
        if not self.type_name:
            if type(value) == float:
                self.type_name = 'qreal'
            elif type(value) == int:
                self.type_name = 'int'
            elif self.name.startswith('color_'):
                self.type_name = 'QColor'
            else:
                raise ValueError('Cannot extract type name from value "{}" for property "{}"'.format(value, self.name))

    def get_value(self, theme_enum_value=''):
        return self.values.get(theme_enum_value)

    def property_declaration(self):
        assert self.type_name, 'No values have been set for property {}'.format(self.name)
        if self.json_info.enum_type == 'ScreenSize':
            notify_signal = 'screenSizeChanged_parameterless'
        elif self.json_info.enum_type == 'ColorScheme':
            notify_signal = 'colorSchemeChanged_parameterless'
        elif not self.json_info.enum_type:
            notify_signal = None
        else:
            raise ValueError('unrecognized enum type "{}" for property {}').format(self.json_info.enum_type, self.name)
        notify_or_constant = 'NOTIFY {}'.format(notify_signal) if notify_signal else 'CONSTANT'
        return '\tQ_PROPERTY({} {} READ {} {} FINAL)'.format(self.type_name, self.name, self.name, notify_or_constant)

    def property_accessor(self):
        assert self.type_name, 'No values have been for property {}'.format(self.name)
        if self.json_info.enum_type == 'ScreenSize':
            try:
                five_inch_value = self.values['FiveInch']
                seven_inch_value = self.values['SevenInch']
            except KeyError:
                raise ValueError('JSON missing 5" or 7" value for property "{}"'.format(self.name))
            if five_inch_value == seven_inch_value:
                return self.constant_property_accessor(five_inch_value)
            else:
                return self.conditional_property_accessor('m_screenSize == Theme::FiveInch', five_inch_value, seven_inch_value)
        elif self.json_info.enum_type == 'ColorScheme':
            try:
                dark_rgba = self.values['Dark']
                light_rgba = self.values['Light']
            except KeyError:
                raise ValueError('JSON missing dark or light value for property "{}"'.format(self.name))
            if dark_rgba == light_rgba:
                return self.constant_property_accessor(dark_rgba)
            else:
                return self.conditional_property_accessor('m_colorScheme == Theme::Dark', dark_rgba, light_rgba)
        elif not self.json_info.enum_type:
            return self.constant_property_accessor(self.values[""])
        else:
            raise ValueError('Cannot create property_accessor for property "{}"'.format(self.name))

    def conditional_property_accessor(self, condition, value1, value2):
        return spaces_to_tabs('''
    {type_name} {name}() const {{
        return {condition} ? {value1} : {value2};
    }}'''.format(type_name=self.type_name, name=self.name, condition=condition, value1=qt_value_string(self.type_name, value1), value2=qt_value_string(self.type_name, value2)))

    def constant_property_accessor(self, constant_value):
        return spaces_to_tabs('''
    {type_name} {name}() const {{
        return {value};
    }}'''.format(type_name=self.type_name, name=self.name, value=qt_value_string(self.type_name, constant_value)))

class JsonFileInfo:
    theme_enums = {
        'FiveInch': 'ScreenSize',
        'SevenInch': 'ScreenSize',
        'Light': 'ColorScheme',
        'Dark': 'ColorScheme',
    }

    def __init__(self, filename, enum_type=None, enum_value=None):
        self.filename = filename
        self.enum_type = enum_type
        self.enum_value = enum_value

    @staticmethod
    def from_json_filename(filename):
        file_base_name = JsonFileInfo.json_file_basename(filename)
        theme_enum_type = JsonFileInfo.theme_enums.get(file_base_name)
        if not theme_enum_type:
            return JsonFileInfo(filename)
        return JsonFileInfo(filename, theme_enum_type, file_base_name)

    @staticmethod
    def json_file_basename(filename):
        return os.path.splitext(os.path.basename(filename))[0]

class JsonThemeParser:
    def __init__(self):
        self.theme_properties = {}

    def parse_theme_subdir(self, theme_subdir):
        unparsed_properties = {}
        for filename in os.listdir(theme_subdir):
            json_info = JsonFileInfo.from_json_filename(filename)
            with open(os.path.join(theme_subdir, filename)) as f:
                # Step 1: parse theme properties that have simple values
                json_input = json.loads(f.read())
                for property_name, property_value in json_input.items():
                    if isinstance(property_value, str) and '_' in property_value:
                        unparsed_properties.setdefault(filename, {})[property_name] = property_value
                    else:
                        self.add_property(property_name, property_value, json_info)

        # Step 2: parse theme values that are references to other theme properties
        for filename, referenced_properties in unparsed_properties.items():
            json_info = JsonFileInfo.from_json_filename(filename)
            nested_references = {}
            for property_name, referenced_property_name in referenced_properties.items():
                referenced_property = self.theme_properties.get(referenced_property_name)
                if referenced_property:
                    property_value = referenced_property.get_value() or referenced_property.get_value(json_info.enum_value)
                    if property_value:
                        self.add_property(property_name, property_value, json_info)
                        continue
                # if the property or value is not found, this must be a nested reference, i.e. the
                # value is a reference to another referenced value
                nested_references[property_name] = referenced_property_name
            # Step 3: parse nested property references within this file
            for property_name, referenced_property_name in nested_references.items():
                referenced_property = self.theme_properties.get(referenced_property_name)
                if not referenced_property:
                    raise ValueError('Bad json value: "{}" value is {} but cannot find another theme property with this name'.format(property_name, referenced_property_name))
                property_value = referenced_property.get_value() or referenced_property.get_value(json_info.enum_value)
                if not property_value:
                    raise ValueError('Cannot find property value for theme {}'.format(json_info.enum_value))
                self.add_property(property_name, property_value, json_info)

    def add_property(self, property_name, value, json_info):
        if json_info.enum_type:
            # This value changes depending on geometry or color
            theme_property = self.theme_properties.get(property_name) or ThemeProperty(property_name, json_info)
            theme_property.set_value(value, json_info.enum_value)
            self.theme_properties[property_name] = theme_property
        else:
            # This is a constant value, which does not change depending on geometry/color
            theme_property = ThemeProperty(property_name, json_info)
            theme_property.set_value(value)
            self.theme_properties[property_name] = theme_property

    def sorted_theme_properties(self):
        return sorted(self.theme_properties.values(), key=lambda theme_property: theme_property.name)

def generate_theme_code(themes_dir, output_header_name):
    parser = JsonThemeParser()
    for subdir in os.listdir(themes_dir):
        parser.parse_theme_subdir(os.path.join(themes_dir, subdir))

    theme_properties = parser.sorted_theme_properties()
    property_declarations = [theme_property.property_declaration() for theme_property in theme_properties]
    property_accessors = [theme_property.property_accessor() for theme_property in theme_properties]
    output_template = HEADER_TEMPLATE % ('\n'.join(property_declarations), '\n'.join(property_accessors))
    with open(output_header_name, 'w') as f:
        f.write(output_template)

if __name__ == '__main__':
    themes_dir, output_header_name = sys.argv[1:3]
    print('Generating theme file {} from theme directory {}'.format(output_header_name, themes_dir))
    generate_theme_code(themes_dir, output_header_name)

