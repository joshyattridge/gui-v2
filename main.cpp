/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "language.h"
#include "logging.h"
#include "theme.h"

#include <velib/qt/v_busitems.h>
#include <velib/qt/ve_qitems_dbus.hpp>

#include <QTranslator>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QScreen>

#include <QtDebug>

Q_LOGGING_CATEGORY(venusGui, "venus.gui")

int main(int argc, char *argv[])
{
	/* QML type registrations.  As we (currently) don't create an installed module,
	   we need to register them into the appropriate type namespace manually. */
	qmlRegisterSingletonType<Victron::VenusOS::Theme>(
		"Victron.VenusOS", 2, 0, "Theme",
		&Victron::VenusOS::Theme::instance);
	qmlRegisterSingletonType<Victron::VenusOS::Language>(
		"Victron.VenusOS", 2, 0, "Language",
		[](QQmlEngine *engine, QJSEngine *) -> QObject* {
			return new Victron::VenusOS::Language(engine);
		});

	/* data sources */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Generators.qml")),
		"Victron.VenusOS", 2, 0, "Generators");

	/* controls */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Button.qml")),
		"Victron.VenusOS", 2, 0, "Button");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/ComboBox.qml")),
		"Victron.VenusOS", 2, 0, "ComboBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Label.qml")),
		"Victron.VenusOS", 2, 0, "Label");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/ProgressBar.qml")),
		"Victron.VenusOS", 2, 0, "ProgressBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/RadioButton.qml")),
		"Victron.VenusOS", 2, 0, "RadioButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Slider.qml")),
		"Victron.VenusOS", 2, 0, "Slider");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/SpinBox.qml")),
		"Victron.VenusOS", 2, 0, "SpinBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Switch.qml")),
		"Victron.VenusOS", 2, 0, "Switch");

	/* components */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ActionButton.qml")),
		"Victron.VenusOS", 2, 0, "ActionButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Arc.qml")),
		"Victron.VenusOS", 2, 0, "Arc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ArcGauge.qml")),
		"Victron.VenusOS", 2, 0, "ArcGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/AsymmetricRoundedRectangle.qml")),
		"Victron.VenusOS", 2, 0, "AsymmetricRoundedRectangle");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/BarChart.qml")),
		"Victron.VenusOS", 2, 0, "BarChart");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularMultiGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularMultiGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularSingleGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularSingleGauge");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Gauges.qml")),
		"Victron.VenusOS", 2, 0, "Gauges");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ControlCard.qml")),
		"Victron.VenusOS", 2, 0, "ControlCard");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/ControlCardsModel.qml")),
		"Victron.VenusOS", 2, 0, "ControlCardsModel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ControlValue.qml")),
		"Victron.VenusOS", 2, 0, "ControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ButtonControlValue.qml")),
		"Victron.VenusOS", 2, 0, "ButtonControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/RadioButtonControlValue.qml")),
		"Victron.VenusOS", 2, 0, "RadioButtonControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SwitchControlValue.qml")),
		"Victron.VenusOS", 2, 0, "SwitchControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/MainView.qml")),
		"Victron.VenusOS", 2, 0, "MainView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/GeneratorIconLabel.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorIconLabel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ModalDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavBar.qml")),
		"Victron.VenusOS", 2, 0, "NavBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavButton.qml")),
		"Victron.VenusOS", 2, 0, "NavButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/PageStack.qml")),
		"Victron.VenusOS", 2, 0, "PageStack");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Preferences.qml")),
		"Victron.VenusOS", 2, 0, "Preferences");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ProgressArc.qml")),
		"Victron.VenusOS", 2, 0, "ProgressArc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ScaledArc.qml")),
		"Victron.VenusOS", 2, 0, "ScaledArc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ScaledArcGauge.qml")),
		"Victron.VenusOS", 2, 0, "ScaledArcGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SegmentedButtonRow.qml")),
		"Victron.VenusOS", 2, 0, "SegmentedButtonRow");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SeparatorBar.qml")),
		"Victron.VenusOS", 2, 0, "SeparatorBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SolarYieldGraph.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldGraph");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SplashView.qml")),
		"Victron.VenusOS", 2, 0, "SplashView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/StatusBar.qml")),
		"Victron.VenusOS", 2, 0, "StatusBar");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/SwitchesModel.qml")),
		"Victron.VenusOS", 2, 0, "SwitchesModel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ThreePhaseDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ThreePhaseDisplay");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ToastNotification.qml")),
		"Victron.VenusOS", 2, 0, "ToastNotification");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Units.qml")),
		"Victron.VenusOS", 2, 0, "Units");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ValueDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ValueDisplay");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/VenusFont.qml")),
		"Victron.VenusOS", 2, 0, "VenusFont");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/WeatherDetails.qml")),
		"Victron.VenusOS", 2, 0, "WeatherDetails");

	/* widgets */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/OverviewWidget.qml")),
		"Victron.VenusOS", 2, 0, "OverviewWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/SegmentedWidget.qml")),
		"Victron.VenusOS", 2, 0, "SegmentedWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/AlternatorWidget.qml")),
		"Victron.VenusOS", 2, 0, "AlternatorWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/GeneratorWidget.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/GridWidget.qml")),
		"Victron.VenusOS", 2, 0, "GridWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/ShoreWidget.qml")),
		"Victron.VenusOS", 2, 0, "ShoreWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/SolarYieldWidget.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WindWidget.qml")),
		"Victron.VenusOS", 2, 0, "WindWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/InverterWidget.qml")),
		"Victron.VenusOS", 2, 0, "InverterWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/BatteryWidget.qml")),
		"Victron.VenusOS", 2, 0, "BatteryWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/AcLoadsWidget.qml")),
		"Victron.VenusOS", 2, 0, "AcLoadsWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/DcLoadsWidget.qml")),
		"Victron.VenusOS", 2, 0, "DcLoadsWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnector.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnector");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnectorPath.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnectorPath");

	/* control cards */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/ESSCard.qml")),
		"Victron.VenusOS", 2, 0, "ESSCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/GeneratorCard.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/InverterCard.qml")),
		"Victron.VenusOS", 2, 0, "InverterCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/SwitchesCard.qml")),
		"Victron.VenusOS", 2, 0, "SwitchesCard");

	/* dialogs */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/DialogManager.qml")),
		"Victron.VenusOS", 2, 0, "DialogManager");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/ModalDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/ModalWarningDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalWarningDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/InputCurrentLimitDialog.qml")),
		"Victron.VenusOS", 2, 0, "InputCurrentLimitDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/InverterChargerModeDialog.qml")),
		"Victron.VenusOS", 2, 0, "InverterChargerModeDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/GeneratorDisableAutostartDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDisableAutostartDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/GeneratorDurationSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDurationSelectorDialog");

	/* pages */
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/pages/PageManager.qml")),
		"Victron.VenusOS", 2, 0, "PageManager");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/Page.qml")),
		"Victron.VenusOS", 2, 0, "Page");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/MainPage.qml")),
		"Victron.VenusOS", 2, 0, "MainPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/ControlCardsPage.qml")),
		"Victron.VenusOS", 2, 0, "ControlCardsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/LevelsPage.qml")),
		"Victron.VenusOS", 2, 0, "LevelsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/OverviewPage.qml")),
		"Victron.VenusOS", 2, 0, "OverviewPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/SettingsPage.qml")),
		"Victron.VenusOS", 2, 0, "SettingsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefPage.qml")),
		"Victron.VenusOS", 2, 0, "BriefPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/NotificationsPage.qml")),
		"Victron.VenusOS", 2, 0, "NotificationsPage");

	// TODO: the following are components, not pages, and should be moved.
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefMonitorPanel.qml")),
		"Victron.VenusOS", 2, 0, "BriefMonitorPanel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/GeneratorMiniGauge.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorMiniGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/LoadMiniGauge.qml")),
		"Victron.VenusOS", 2, 0, "LoadMiniGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/GeneratorLeftGauge.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorLeftGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/GeneratorRightGauge.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorRightGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/LoadGauge.qml")),
		"Victron.VenusOS", 2, 0, "LoadGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/SolarYieldGauge.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldGauge");

	qmlRegisterType<VeQuickItem>("Victron.Velib", 1, 0, "VeQuickItem");

	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationName("Venus");
	QGuiApplication::setApplicationVersion("2.0");

	QCommandLineParser parser;
	parser.setApplicationDescription("Venus GUI");
	parser.addHelpOption();
	parser.addVersionOption();

	QCommandLineOption dbusAddress({ "d",  "dbus" },
		QGuiApplication::tr("main", "Specify the D-Bus address to connect to"),
		QGuiApplication::tr("main", "dbus"));
	parser.addOption(dbusAddress);

	QCommandLineOption dbusDefault(QString("dbus-default"),
		QGuiApplication::tr("main", "Use the default D-Bus address to connect to"),
		QString(),
		QString("tcp:host=localhost,port=3000"));
	parser.addOption(dbusDefault);

	parser.process(app);

	QScopedPointer<VeQItemDbusProducer> producer(new VeQItemDbusProducer(VeQItems::getRoot(), "dbus"));
	QScopedPointer<VeQItemSettings> settings;

	if (parser.isSet(dbusAddress) || parser.isSet(dbusDefault)) {
		// Default to the session bus on the pc
		VBusItems::setConnectionType(QDBusConnection::SessionBus);
		VBusItems::setDBusAddress(parser.value(parser.isSet(dbusAddress) ? dbusAddress : dbusDefault));

		QDBusConnection dbus = VBusItems::getConnection();
		if (dbus.isConnected()) {
			producer->open(dbus);
			settings.reset(new VeQItemDbusSettings(producer->services(), QString("com.victronenergy.settings")));
		} else {
			qCritical() << "DBus connection failed.";
			exit(EXIT_FAILURE);
		}
	} else {
		producer->open(VBusItems::getConnection());
	}

	/* Load appropriate translations, e.g. :/i18n/venus-gui-v2_fr.qm */
	QTranslator translator;
	if (translator.load(
		QLocale(),
		QLatin1String("venus-gui-v2"),
		QLatin1String("_"),
		QLatin1String(":/i18n"))) {
		QCoreApplication::installTranslator(&translator);
		qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale().name();
	} else {
		qCWarning(venusGui) << "Unable to load translations for locale" << QLocale().name();
	}

	QQmlEngine engine;
	engine.setProperty("colorScheme", Victron::VenusOS::Theme::Dark);
	engine.setProperty("screenSize", Victron::VenusOS::Theme::FiveInch);
	//(QGuiApplication::primaryScreen()->availableSize().height() < 1024)
	//		? Victron::VenusOS::Theme::FiveInch
	//		: Victron::VenusOS::Theme::SevenInch);
	engine.rootContext()->setContextProperty("dbusConnected", VBusItems::getConnection().isConnected());

	QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/main.qml")));
	if (component.isError()) {
		qWarning() << component.errorString();
		return EXIT_FAILURE;
	}

	QScopedPointer<QObject> object(component.beginCreate(engine.rootContext()));
	const auto window = qobject_cast<QQuickWindow *>(object.data());
	if (!window) {
		component.completeCreate();
		qWarning() << "The scene root item is not a window." << object.data();
		return EXIT_FAILURE;
	}

	engine.setIncubationController(window->incubationController());
	/* Write to window properties here to perform any additional initialization
	   before initial binding evaluation. */
	component.completeCreate();

#if defined(VENUS_DESKTOP_BUILD)
	const bool desktop(true);
#else
	const bool desktop(QGuiApplication::primaryScreen()->availableSize().height() > 600);
#endif
	if (desktop) {
		window->show();
	} else {
		window->showFullScreen();
	}

	return app.exec();
}
