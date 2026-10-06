/// Localized names for the shipped PIDs.
///
/// [Pid.name] and [Pid.shortName] are the author's own text: a custom PID or a
/// catalog signal has to render exactly what somebody typed, in every language.
/// The built-ins are ours, so they carry [Pid.l10nId] and are named from the
/// ARBs instead. The same split the glossary records for the enums that came
/// before these — identity in `lib/obd`, words in the ARBs — so a definition
/// with no [Pid.l10nId] is drawn from its own fields and cannot disagree with
/// what a translated one shows.
library;

import '../obd/pid/pid.dart';

import 'generated/app_localizations.dart';

/// The shipped title for [pid], or [Pid.name] when it ships no translation.
String pidDisplayName(AppLocalizations l10n, Pid pid) {
  return switch (pid.l10nId) {
    'engineRpm' => l10n.pidNameEngineRpm,
    'vehicleSpeed' => l10n.pidNameVehicleSpeed,
    'coolantTemp' => l10n.pidNameCoolantTemp,
    'intakeAirTemp' => l10n.pidNameIntakeAirTemp,
    'engineLoad' => l10n.pidNameEngineLoad,
    'throttlePosition' => l10n.pidNameThrottlePosition,
    'manifoldPressure' => l10n.pidNameManifoldPressure,
    'mafRate' => l10n.pidNameMafRate,
    'timingAdvance' => l10n.pidNameTimingAdvance,
    'fuelPressure' => l10n.pidNameFuelPressure,
    'fuelLevel' => l10n.pidNameFuelLevel,
    'barometricPressure' => l10n.pidNameBarometricPressure,
    'controlModuleVoltage' => l10n.pidNameControlModuleVoltage,
    'ambientAirTemp' => l10n.pidNameAmbientAirTemp,
    'engineOilTemp' => l10n.pidNameEngineOilTemp,
    'engineFuelRate' => l10n.pidNameEngineFuelRate,
    'shortFuelTrimB1' => l10n.pidNameShortFuelTrimB1,
    'longFuelTrimB1' => l10n.pidNameLongFuelTrimB1,
    'runTime' => l10n.pidNameRunTime,
    'distanceWithMil' => l10n.pidNameDistanceWithMil,
    'absoluteLoad' => l10n.pidNameAbsoluteLoad,
    'commandedEgr' => l10n.pidNameCommandedEgr,
    'relativeThrottle' => l10n.pidNameRelativeThrottle,
    'boostPressure' => l10n.pidNameBoostPressure,
    'speedMph' => l10n.pidNameSpeedMph,
    _ => pid.name,
  };
}

/// The shipped gauge-face label for [pid], or [Pid.shortName] when it has none.
String pidDisplayShortName(AppLocalizations l10n, Pid pid) {
  return switch (pid.l10nId) {
    'engineRpm' => l10n.pidShortEngineRpm,
    'vehicleSpeed' => l10n.pidShortVehicleSpeed,
    'coolantTemp' => l10n.pidShortCoolantTemp,
    'intakeAirTemp' => l10n.pidShortIntakeAirTemp,
    'engineLoad' => l10n.pidShortEngineLoad,
    'throttlePosition' => l10n.pidShortThrottlePosition,
    'manifoldPressure' => l10n.pidShortManifoldPressure,
    'mafRate' => l10n.pidShortMafRate,
    'timingAdvance' => l10n.pidShortTimingAdvance,
    'fuelPressure' => l10n.pidShortFuelPressure,
    'fuelLevel' => l10n.pidShortFuelLevel,
    'barometricPressure' => l10n.pidShortBarometricPressure,
    'controlModuleVoltage' => l10n.pidShortControlModuleVoltage,
    'ambientAirTemp' => l10n.pidShortAmbientAirTemp,
    'engineOilTemp' => l10n.pidShortEngineOilTemp,
    'engineFuelRate' => l10n.pidShortEngineFuelRate,
    'shortFuelTrimB1' => l10n.pidShortShortFuelTrimB1,
    'longFuelTrimB1' => l10n.pidShortLongFuelTrimB1,
    'runTime' => l10n.pidShortRunTime,
    'distanceWithMil' => l10n.pidShortDistanceWithMil,
    'absoluteLoad' => l10n.pidShortAbsoluteLoad,
    'commandedEgr' => l10n.pidShortCommandedEgr,
    'relativeThrottle' => l10n.pidShortRelativeThrottle,
    'boostPressure' => l10n.pidShortBoostPressure,
    'speedMph' => l10n.pidShortSpeedMph,
    _ => pid.shortName,
  };
}

/// What a gauge face or lane chip shows for [pid]: the short name when the
/// definition has one, the full name when it does not.
String pidGaugeLabel(AppLocalizations l10n, Pid pid) {
  final short = pidDisplayShortName(l10n, pid);
  return short.isEmpty ? pidDisplayName(l10n, pid) : short;
}
