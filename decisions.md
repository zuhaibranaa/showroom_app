# Decisions — Showroom App

This file records architectural and design decisions made for the showroom_app Flutter codebase.

## 1. Role-Based Access Control (RBAC)

### Roles
Three roles are defined in `lib/models/user_role.dart`:
- `super_admin` — full platform access; can create agencies, invite any admin, manage options/retail prices
- `admin` — staff access scoped to assigned agencies (`user.agencyIds`)
- `dealer` — dealer portal access; permissions scoped per module

### Authorization Enforcement Layer
All permission checks are **client-side** (Dart/Flutter). There is **no server-side authorization** in Firestore or Storage rules (both were previously `allow read, write: if true`). Server-side rules have been added to `firestore.rules` and `storage.rules` as of this decision, but the primary enforcement remains in the UI layer via `AccessService`.

**Rationale:** Client-side RBAC is simpler to implement and sufficient for the current threat model. Server-side rules provide defense-in-depth but are not the primary enforcement mechanism.

### AccessService
Centralized in `lib/providers/access_provider.dart`. Provides static helpers:
- `isSuperAdmin`, `isAdmin`, `isDealer`, `isStaff`, `isAgencyOwner`, `canInviteAgencyAdmin`
- `dealerCanView/Create/Edit` for per-dealer module permissions
- Riverpod providers for agency-scoped data: `accessibleAgenciesProvider`, `accessibleVehiclesProvider`, `accessibleSalesProvider`, `accessibleDealersProvider`, `accessibleExpensesProvider`

### Dealer Module Permissions
Each `DealerModel` carries a `DealerPermissions` object with `ModulePermission` for three modules: `vehicles`, `sales`, `dealers`. Each module has `view`, `create`, `edit` booleans.

**Decision:** `ModulePermission.view` defaults to `false` (deny-by-default). New dealers see nothing until explicitly granted permissions.

## 2. Authentication & Session Management

### Auth Provider
Firebase Auth (`firebase_auth`) handles authentication. User profiles are stored in Firestore (`users` collection) via `UserService`.

### Dealer Provisioning
Two paths:
1. **Admin-created:** Admin creates `DealerModel` via `/dealers/add`. Optionally creates a Firebase Auth account with temp password, links dealer to user, sets `mustChangePassword: true`.
2. **Dealer self-registration:** `/dealer-register` requires an existing dealer record matched by email. Sets `mustChangePassword: true` to match admin-created dealers.

### Dealer Password Reset
Dealers with `mustChangePassword: true` are forced to `/change-password` before accessing any other route (enforced in `router.dart` redirect).

### Deactivated Users
`UserModel.isActive` is enforced in the router: deactivated users are redirected to `/login`.

## 3. Data Scoping

### Agency-Scoped Data
Admins see only data from agencies in `user.agencyIds`. Super admins see all data. Scoping is implemented via:
- `accessible*Providers` (Riverpod) that merge streams per agency
- `get*ByAgency` service methods
- `_mergeAgencyStreams` helper that deduplicates by document ID

## 4. Route Guards

`router.dart` (`GoRouter.redirect`):
- Unauthenticated → `/login` (unless on auth page)
- Authenticated on auth page → `/dashboard`
- Deactivated user → `/login`
- Dealer with `mustChangePassword` → `/change-password`
- Dealer restricted to dealer routes + `/profile` + `/biometric-settings`
- `/agencies` and `/admins` restricted to super admin or agency owner

## 5. Navigation Guards

`app_shell.dart` filters drawer/bottom-nav items:
- `superAdminOnly`: Reports, Admins, Retail prices, Options
- `staffOnly`: Pending payments (Sales), Dealers
- Default (all logged-in users): Dashboard, Vehicles, Sales, Documents, Biometrics, Expenses, Registration & transfer, Agencies, Profile

## 6. Admin Invites

Admins are created via an invite flow:
1. Super admin or agency owner creates an invite in `adminInvites` Firestore collection with `agencyIds` and `isAgencyOwner`
2. Invited person registers via `/register`, which requires a matching invite
3. Invite is deleted after registration

**Constraints:**
- Super admin can invite for any agency
- Agency owner can invite only for their own agencies
- Only super admins can create new agency owners

## 7. Firestore & Storage Security Rules

Previously `allow read, write: if true` (fully open). Updated to role-based rules:
- `firestore.rules`: role-based read/write per collection (`users`, `adminInvites`, `agencies`, `dealers`, `vehicles`, `sales`, `expenses`)
- `storage.rules`: role-based read/write per path prefix (`vehicles/{agencyId}/`, `sales/{agencyId}/`)

Both deny all other collections/paths by default.

## 8. State Management

Riverpod (`flutter_riverpod`) is used for all state management:
- Providers for services, auth state, user profile, and scoped data
- StateNotifier providers for mutations (login, register, create/update/delete operations)

## 9. Localization / Currency

All monetary values use "Rs " prefix (Pakistani Rupees). Number formatting via `NumberFormat.currency(symbol: 'Rs ')`.

## 10. Image Uploads

Images uploaded to Cloudinary via `CloudinaryService`. Organized by folder:
- `vehicles/{agencyId}/`
- `sales/{agencyId}/`

## Known Limitations / Tech Debt

1. **Client-side RBAC primary enforcement:** Server-side rules exist but client-side `AccessService` checks are the primary enforcement. A determined attacker with direct Firebase SDK access could bypass client-side checks.

2. **`options_screen.dart` Primitive Obsession:** `_kind` uses `String` literals (`'make'`, `'model'`, `'expense_category'`, `'checklist'`) instead of an enum. Converting to enum would require changes across `option_merge.dart`, `operations_models.dart`, `operations_provider.dart`, and Firestore serialization.

3. **`sale_service.dart` Feature Envy:** `SaleService` reads `commissionPercent` from dealer Firestore documents directly rather than through a domain model. This is inherent to the Firestore-based architecture where dealer data lives in documents.

4. **`expense_list_screen.dart` / `user_service.dart` info lints:** Two info-level `use_null_aware_elements` lints remain because the null-aware alternative would change behavior (adding `"null"` strings or null map values).
