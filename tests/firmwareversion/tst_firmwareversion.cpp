/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "enums.h"

template <typename T> static QObject *singletonFactory(QQmlEngine *, QJSEngine *)
{
	return new T;
}

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::Enums>("Victron.VenusOS", 2, 0, "VenusOS");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_firmwareversion", nullptr);
}
