# MobAI Requirements Trace (from `WMS_Hackathon_DataPack.tex`)

## Scope used
- Roles: `ADMIN`, `SUPERVISOR`, `EMPLOYEE`
- Operations: `Receipt`, `Transfer`, `Preparation`, `Picking`, `Delivery`
- AI controls: validation + override with justification
- Warehouse focus: **B7 only**

## Implemented in this update
- Role-based login routing:
  - `ADMIN` → `/admin`
  - `SUPERVISOR` → `/supervisor`
  - `EMPLOYEE` → `/employee`
- Employee view shows **validated tasks only** (FR-6)
- New supervisor area with:
  - operations overview
  - warehouse map
  - AI validation/override panel
  - audit logs
- AI override now requests a **justification** (FR-8)

## FR coverage snapshot
- FR-1 / FR-2 / FR-3: ✅ basic auth screen and role separation in UI
- FR-5 / FR-7 / FR-8: ✅ supervisor/admin validation and override UI
- FR-6: ✅ employee restricted to validated tasks
- FR-9 / FR-47: ✅ represented in audit/override panels (UI level)
- FR-10..57 / FR-70..71: ⏳ requires backend transactions + offline sync integration

## Next backend integration
1. Connect login to Spring auth endpoint.
2. Replace mock validation tasks with backend orders (`COMMAND`, `PREPARATION`, `PICKING`, `DELIVERY`).
3. Persist override logs with immutable storage.
4. Add offline queue + reconciliation for stock movement sync.
5. Enforce role restrictions server-side for all protected endpoints.
