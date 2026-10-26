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
- **Acting as a user**: there is no authentication yet; the "Acting as" select in the navigation bar chooses the user
  every action is performed as.
- **New setup steps**: install libvips (see Setup) and run `bin/rails db:migrate db:seed`.

## Course

Web Technologies — Universidad de los Andes, 2026