class FirestoreCollections {
  static const users = 'users';
  static const animals = 'animals';
  static const manualLogs = 'manualLogs';
  static const activityLogs = 'activityLogs';
  static const farms = 'farms';
  static const partners = 'partners';
  static const adminAudit = 'adminAudit';
  static const config = 'config';
  static const aiRateLimit = 'aiRateLimit';
}

class FirestoreFields {
  static const earTag = 'earTag';
  static const earTagId = 'earTag.id';
  static const earTagColor = 'earTag.color';
  static const type = 'type';
  static const breed = 'breed';
  static const birthDate = 'birthDate';
  static const pregnancyHistory = 'pregnancyHistory';
  static const birthLog = 'birthLog';
  static const healthLogs = 'healthLogs';
  static const photoUrls = 'photoUrls';
  static const farmId = 'farmId';

  static const manualLogType = 'type';
  static const manualLogAnimalRefs = 'animalRefs';
  static const manualLogNotes = 'notes';
  static const manualLogPerformedBy = 'performedBy';
  static const manualLogTimestamp = 'timestamp';

  static const activityLogAction = 'action';
  static const activityLogEntity = 'entity';
  static const activityLogEntityId = 'entityId';
  static const activityLogDetails = 'details';
  static const activityLogPerformedBy = 'performedBy';
  static const activityLogTimestamp = 'timestamp';
}
