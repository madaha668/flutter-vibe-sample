• Feature Proposal: Visual Notes Support in Nomad Notes RN

  - Objective
      - Extend Nomad Notes RN so each note may include one photo captured from the device camera or gallery.
      - Backend stores images locally, applies OCR and object-identification via pluggable services, and surfaces
        results alongside note content.
  - Scope & Workflow
      - Mobile client adds “Add Photo Note” flow parallel to existing text-note creation.
      - Capture/import photo → preview & optional annotate → upload with note metadata.
      - Server accepts multipart payload (one image ≤10 MB + note fields), persists image, records analysis results,
        and returns enriched note data.
  - Frontend Milestones (React Native + Expo)
      1. Camera & Media Access
          - Integrate expo-camera for capture, expo-image-picker for gallery import.
          - Use expo-permissions for runtime consent; gate UI when declined.
          - Compress image client-side (expo-image-manipulator) to enforce 10 MB ceiling.
      2. UI/State Updates
          - New picture-note entry point in notes list FAB menu.
          - Modify note editor to show thumbnail, size indicator, remove option, and save button states.
          - Extend React Query mutations to handle multipart upload + optimistic placeholder state.
      3. Data Handling
          - API layer posts FormData to new /api/notes/ endpoint variant (single file + JSON).
          - Receive OCR text/object tags from response to display in detail views or search filters.
  - Backend Milestones (Django)
      1. Storage & Models
          - Create NoteImage model referencing Note, storing local file path, checksum, size metadata, and analysis
            fields (OCR text, labels).
          - Configure media root (e.g., backend/media/notes/) with Docker volume separate from SQLite data.
      2. API Enhancements
          - Update note create/update endpoints to accept multipart uploads (single image).
          - Validate file size/type, reject >10 MB, enforce max-one-photo rule, and return serialized image metadata.
          - Provide endpoints to retrieve processed OCR/object-tag data.
      3. Pluggable Analysis Services
          - Define service interface (e.g., VisionProvider protocol) with analyze(image_path) -> VisionResult.
          - Implement default local adapter (e.g., Tesseract + lightweight object detector) and allow env-configured
            remote adapter (HTTP).
          - Execute analysis asynchronously (Celery task or background thread) and update NoteImage record; expose
            status in API.
  - Infrastructure & Tooling
      - Docker: mount media/ volume to persist images; ensure permissions inside container.
      - Create migration scripts and update fixtures/tests to cover media paths.
      - Document CLI commands for running local OCR/object detection requirements.
  - Risks & Mitigations
      - Large image processing delays → enqueue async jobs; respond immediately with pending status.
      - Local storage growth → plan retention policy or future migration to external storage.
      - Pluggable AI services contract drift → define versioned interface and health-check endpoint.
  - Validation Strategy
      - Manual end-to-end tests on iOS/Android simulators with varied image sizes and permission flows.
      - Backend unit tests for upload constraints, serialization, and vision provider adapter contract.
      - Integration test simulating full note creation, analysis trigger, and retrieval of OCR/labels.
  - Documentation & Follow-up
      - Update nomad_notes_rn/README.md with photo-note usage, env requirements (NOMAD_API_URL).
      - Extend backend docs to cover media storage, analysis service configuration, and operational considerations.
      - Plan future enhancement: search/filter notes by OCR text or detected objects once data pipeline stabilizes.
