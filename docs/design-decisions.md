# Design Decisions

## Entities added beyond the project description

**`property_amenities` and `listing_photos`** aren't named as tables in the project description, only as
concepts ("the amenities it offers", "photographs of the room"). `property_amenities` is the join table
between properties and the amenities catalog — a plain many-to-many, no attributes of its own, so it
stays a simple join rather than a richer entity. `listing_photos` exists because a listing "carries
photographs", plural, so photos are their own table (one listing, many photos) rather than a single
image column on `listings`.

**`saved_listings`** is the join between a seeker and the listings they've bookmarked. Like
`property_amenities`, it carries no data of its own beyond who saved what and when, so it's a plain
join table, not a richer one.

**`reports.resolved_by`** points at the moderator who handled a report. The description says moderators
"review reports and take listings down", which implies someone did the reviewing — that column records
who.

## How the lifecycle of a listing and an application are represented

Both `listings.status` and `applications.status` are plain string columns with a default, the same
pattern used for `repairs.status` in the Wheelhouse labs — not a separate table of states, since the
states are fixed and small in number.

- **Listing**: `draft → published → reserved → rented`, with `withdrawn` reachable from `draft` or
  `published`. A listing moves to `reserved` the moment an application is accepted, and only a
  moderator or the host can move it to `withdrawn`.
- **Application**: `pending → shortlisted → accepted`, with `rejected` reachable from `pending` or
  `shortlisted`, and `withdrawn` reachable from `pending` or `shortlisted` (a seeker can only pull back
  an application that hasn't already been decided). Accepting one application on a listing is the
  single event that also rejects every other pending or shortlisted application on that same listing —
  that's application logic for Assignment 2, not something the schema enforces by itself yet.

## Assumptions made where the description doesn't settle something

- **A property can have listings in different states at once.** The description says a property "may
  have several listings over time, and more than one at once when two rooms are free" — I'm assuming
  that also means one room can be `rented` while another in the same property is still `published`.
- **A host cannot apply to their own listing.** The description states this as a rule for applications,
  but doesn't say whether it's enforced by the schema or by validation — I'm treating it as an
  application-level validation (Assignment 2), since the schema alone can't express "not this specific
  user."
- **`visits.status`** isn't spelled out as an enumerated list in the description, only described in
  prose ("proposed... confirmed... cancelled... completed"). I'm using those four exact words as the
  state values, matching the verbs the description itself uses.