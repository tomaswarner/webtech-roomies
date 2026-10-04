# Model changes since Assignment 1

Writing the migrations and models showed that the Assignment 1 diagram needed a few adjustments.
The updated source is [`domain-model.dbml`](domain-model.dbml) (view it in [dbdiagram.io](https://dbdiagram.io)).

## New columns

- `listings.title`: every listing card and page needs a short headline.
- `listing_photos.caption`: alt text and description for each photo.
- `users.phone`: contact data for hosts and seekers.
- `reports.details`: free text for the reporter. `reports.reason` is now a short category, and `resolved_by` became `resolved_by_id` to follow Rails conventions.
- `created_at` / `updated_at` on neighborhoods, amenities and the join tables (`property_amenities`, `saved_listings`), and `updated_at` on `listing_photos`.

## New unique indexes

- `property_amenities [property_id, amenity_id]`: a property lists an amenity once.
- `applications [listing_id, seeker_id]`: a seeker cannot apply twice to the same listing.
- `saved_listings [seeker_id, listing_id]`: a listing is saved once per seeker.
- `reviews.visit_id`: one review per visit.
- Partial unique index on `applications.listing_id` where `status = 'accepted'`: a listing has at most one accepted application.
- Check constraint on `reviews.rating` (1 to 5).

## Rules decided while implementing

- `available_on` is compared with the listing's creation date (not today) and only applies to `draft` and `published` listings, so reserved and rented listings keep their historical dates.
- A visit can only be created for a `shortlisted` application, must be scheduled after the application was created, and a `completed` visit cannot be in the future.
- A review needs a `completed` visit, and a host cannot review their own property.
