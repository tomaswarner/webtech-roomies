# webtech-roomies

Roomies is a platform that connects people with a free room in a shared home to people looking for a
place to live. This repository holds every deliverable for the Web Technologies course project and
is used for all four assignments and the final demo.

## Group members

- Tomás Warner Sarasua

## Setup

Requirements: Ruby (see `.ruby-version`), PostgreSQL, Node.js, Yarn and **libvips** (used by Active Storage to
build the photo variants; on macOS `brew install vips`).

```
bundle install
yarn install
bin/rails db:create db:migrate db:seed
bin/dev
```

If the database already exists from Assignment 2, run `bin/rails db:migrate db:seed` again: Assignment 3 adds the
Active Storage and Action Text tables, and the seeds attach the photos in `db/seeds/photos` to the listings.

`bin/dev` starts the Rails server and the Bootstrap CSS build. The app runs at http://localhost:3000.

## Repository structure

webtech-roomies/
├── app/                        # Assignment 2 — Rails application (models, controllers, views)
├── db/                         # Assignment 2 — migrations, schema and seeds
│   └── seeds/photos/           # Assignment 3 — room photographs attached by db/seeds.rb
├── docs/
│   ├── user-stories.md         # Assignment 1 — user stories
│   ├── domain-model.dbml       # Domain model source (dbdiagram.io / DBML), updated in Assignment 2
│   ├── domain-model.png        # Domain model diagram (exported image)
│   ├── design-decisions.md     # Assignment 1 — modeling decisions and assumptions
│   └── model-changes.md        # Assignment 2 — what changed in the model and why
└── README.md                   # this file

## Assignment 1 — User Stories, Domain Model, and Landing Page

- **Landing page**: a static Bootstrap page (navbar, hero, search, featured listings, how it works). It is now
  the root page of the Rails app (`app/views/pages/home.html.erb`).
- **User stories**: [`docs/user-stories.md`](docs/user-stories.md) — covers publishing properties and
  listings, searching as a visitor, applying and withdrawing, shortlisting/visiting/accepting, reviews,
  saved listings, reports, and moderation — from the visitor, member, and moderator roles.
- **Domain model**: [`docs/domain-model.dbml`](docs/domain-model.dbml) (source) and
  [`docs/domain-model.png`](docs/domain-model.png) (diagram). Open the `.dbml` file's contents in
  [dbdiagram.io](https://dbdiagram.io) to view or edit it interactively.
- **Design decisions**: [`docs/design-decisions.md`](docs/design-decisions.md) — entities added beyond
  the project description, the lifecycle of listings and applications, and modeling assumptions.

## Assignment 2 — Rails Application, Models, and Read-Only Views

- **Models**: all entities with associations (including many-to-many), enums, validations and scopes, in `app/models`.
  Database constraints are in `db/migrate`.
- **Views**: read-only `index` and `show` pages for listings, properties, neighborhoods and applications.
  The navbar and footer live in the layout, and the listing card is a single partial (`listings/_listing`).
- **Seeds**: `db/seeds.rb` covers every table. Run `bin/rails db:seed`.
- **Model changes**: [`docs/model-changes.md`](docs/model-changes.md).

## Assignment 3 — CRUD, Photographs, Rich Text, and Hotwire

- **Upload size limit**: listing photographs must be JPEG, PNG, WebP or GIF images of **at most 5 MB each**.
- **Acting as a user**: replaced by real accounts in Assignment 4.
- **New setup steps**: install libvips (see Setup) and run `bin/rails db:migrate db:seed`.

## Assignment 4 — Authentication, Authorization, and JSON API

- **New setup steps**: run `bundle install`, then `bin/rails db:migrate db:seed`.
- The "Acting as" selector of Assignment 3 is gone: the current user is the one who signed in.
- **Authentication** (Rails 8 generator): sign up, sign in and out, password reset by email and an editable profile
  (name, email, phone and a short bio) at `/profile`.
- **Emails**: in development they are not sent, they are written to `tmp/mails` (one file per recipient). The host
  receives an email through Active Job (`deliver_later`) when somebody applies to one of their listings. Previews are
  at `/rails/mailers`.

### Credentials

Every seeded user has the password **`roomies2026`**.

| Role | Email | Notes |
| --- | --- | --- |
| Moderator | `andrea.fuentes@roomies.cl` | Also `ignacio.perez@roomies.cl` |
| Member (host) | `camila.rojas@gmail.com` | Hosts two properties, with a draft listing and applications received |
| Member (host) | `matias.gonzalez@gmail.com` | Hosts two properties, with a draft listing and applications received |
| Member (seeker) | `sofia.morales@miuandes.cl` | Has applications sent to Matías and Benjamín |
| Member (seeker) | `seba.torres@gmail.com` | Has a completed visit that can still be reviewed |

### Roles

- **Visitor** (not signed in): browses and searches published listings, and sees listing pages, property pages and
  reviews. Everything else asks to sign in.
- **Member** (`role: member`, the default): everything a visitor can do, plus creating properties and listings and
  editing or deleting their own, applying to other people's listings, answering (shortlist, reject, accept) the
  applications received on their own listings, proposing and changing visits as host or applicant, reviewing a
  property after their own completed visit, deleting their own reviews and reporting listings.
- **Moderator** (`role: moderator`): everything a member can do, plus seeing drafts and every application, editing or
  deleting (taking down) any property or listing, deleting any review, resolving reports and managing the neighborhoods
  and amenities. A moderator does not answer applications, propose visits or write reviews for others.

Permissions are decided by one Pundit policy per model in `app/policies`. Every controller action calls `authorize` or
`policy_scope`; the inbox and the sent applications are built from `RentalApplicationPolicy::Scope` (the policy of the
`Application` model), and applications and visits are looked up inside their scope, so an id typed in the URL that is
not the user's never loads. A refused action answers 403 with a page that explains why (texts in
`config/locales/pundit.en.yml`) and changes nothing.

### JSON API

Public and read-only, no authentication. It exposes the rooms, never the people: no host, address, applications,
emails, phones or review authors.

**`GET /api/v1/listings`** — published listings, newest first. Optional filters:

| Parameter | Format | Example |
| --- | --- | --- |
| `neighborhood_id` | whole number | `neighborhood_id=3` |
| `max_rent` | positive whole number (CLP) | `max_rent=350000` |
| `available_from` | date `YYYY-MM-DD`: rooms available on or before it | `available_from=2026-12-01` |
| `amenity_ids[]` | whole numbers, the property must have all of them | `amenity_ids[]=1&amenity_ids[]=4` |

```json
[
  {
    "id": 191,
    "title": "Bright room with private bathroom near Pedro de Valdivia",
    "status": "published",
    "monthly_rent": "430000",
    "deposit": "430000",
    "available_on": "2026-11-29",
    "minimum_stay_months": 6,
    "furnished": true,
    "private_bathroom": true,
    "neighborhood": { "id": 117, "name": "Providencia" },
    "property": {
      "property_type": "apartment",
      "bedrooms_count": 3,
      "bathrooms_count": 2,
      "amenities": [ { "id": 157, "name": "24h concierge" }, { "id": 152, "name": "Balcony" } ]
    },
    "photo_url": "http://localhost:3000/rails/active_storage/representations/...",
    "url": "http://localhost:3000/listings/191"
  }
]
```

**`GET /api/v1/listings/:id`** — one published, reserved or rented listing, with the same fields plus `description`
and `house_rules` (plain text).

Money travels as a string. Status codes:

| Status | When | Body |
| --- | --- | --- |
| 200 | Success | The listing or the array of listings |
| 400 | A filter is malformed (e.g. `max_rent=abc`) | `{ "errors": ["max_rent must be a positive whole number"] }` |
| 404 | The listing does not exist, or it is a draft or withdrawn | `{ "errors": ["There is no listing with id 999"] }` |
| 404 | Any other path under `/api/v1` | `{ "errors": ["There is no route for GET /api/v1/..."] }` |

The search page (`/listings`) uses this API: `app/javascript/controllers/listing_search_controller.js` sends the
filters with `fetch` and draws the results without reloading the page.

## Course

Web Technologies — Universidad de los Andes, 2026