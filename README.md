# Gym Adherent

The existing Home, Sessions, Members, and Profile screens are Flutter screens.
Firebase is wired through repositories; it does not create a Firebase project,
write member accounts, or deploy Firestore rules.

## Set up Firebase manually

1. In the Firebase Console, create the project you own (Spark is sufficient).
2. Add an Android app with package name `com.example.salledesport`. The
   `applicationId` is in `android/app/build.gradle.kts`.
3. Download that app's `google-services.json` and place it at
   `android/app/google-services.json`. It is git-ignored; do not publish it in a
   public repository.
4. In Authentication, enable the Email/Password provider.
5. Create Cloud Firestore in **production mode**, choosing a European region
   close to Tunisia (for example `eur3`). Firestore's region cannot be changed
   later.
6. To share the project, open Project settings → Users and permissions → Add
   member, then grant your friend the Editor role. The app must use the same
   `google-services.json` and package name; register another Android app in the
   same Firebase project if a second package name is needed. SHA-1 is not needed
   for Email/Password and is only needed if Google sign-in is added later.
7. Publish Firestore rules and indexes with the Firebase CLI from the project
   root:

   ```shell
   firebase deploy --only firestore
   ```

   The Firebase CLI project is pinned to `sallegym-776db` in `.firebaserc`.
   These rules have no time-based expiry. They deny all other collections and
   access.
8. Run `flutter pub get`, then `flutter run`. Android Firebase options are read
   from the Google Services configuration. You do not need to paste credentials
   or configuration into chat.

## Firestore schema

| Collection/document | Fields used by this app |
| --- | --- |
| `users/{uid}` | `name` (String), `email` (String), `phone` (String), `role` (`admin`, `adherent`, or `coach`; legacy `member` is treated as `adherent`), `createdAt` (Timestamp) |
| Coach-only optional fields | `photoUrl` (String), `specialties` (List<String>), `coachSince` (Timestamp), `rating` (Double), `experienceYears` (Int), `isActive` (Boolean) |
| Member-only fields | `coachId` (String), `goal` (String) |
| `sessions/{sessionId}` | `coachId` (String), `type` (`HIIT`, `Cross`, `Mobilité`), `title` (String), `studio` (String), `startAt` (Timestamp), `durationMin` (Int), `capacity` (Int), `enrolledIds` (List<String>), `createdAt` (Timestamp) |

User document IDs must equal their Firebase Authentication UIDs. Coach
registration creates only that coach's `users/{uid}` document. Assign `admin`
and `adherent` roles through a trusted administrative process; users cannot
change their own role. To add test members, create Email/Password accounts in
Firebase Authentication and then create `users/{their-auth-uid}` documents
with role `adherent` (or legacy `member`), `coachId` set to the coach UID, and
the fields listed above. The app never creates fake members. Attendance
percentage is shown as `—` because no attendance schema was provided.

## Rules summary

- Users can read their own profile and change only their name and phone; the
  role cannot be changed by the account owner.
- Coaches can read only member profiles linked to their coach UID.
- Adherents can read all coach profiles through a role-filtered read-only query;
  they cannot update or delete another user's coach profile.
- A coach can create, edit, and delete only their own sessions.
- Members/adherents can read sessions belonging to their linked coach, and can
  only add or remove their own UID in `enrolledIds`.
- Rules have no expiry date. Console project Editors have administrative access
  through Firebase IAM; share that role only with trusted collaborators.
- Admin, adherent, and coach destinations are guarded in the Flutter UI. These
  guards do not replace Firestore Rules, which remain the authority for data
  access; the admin landing screen currently has no administrative data actions.

## Indexes

The composite indexes used for session and member queries are defined in
[`firestore.indexes.json`](./firestore.indexes.json) and deployed with the
Firestore command above.

## Debug and local verification

The `Exemples (debug)` control appears only in debug builds. It idempotently
adds three sample sessions for the signed-in coach; it never creates users or
runs in release builds. The app uses Firestore's Android offline persistence.

Use the fake repositories for local UI previews without Firebase:

```shell
flutter run --dart-define=USE_FAKE_REPOSITORIES=true
```

Verify the project with:

```shell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Live Firebase Authentication and Firestore reads/writes were verified against
the configured project using the Android emulator.
