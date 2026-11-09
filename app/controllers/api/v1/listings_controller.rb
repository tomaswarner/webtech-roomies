module Api
  module V1
    # Public listing data. It exposes the rooms, never the people: no host, no address, no applications,
    # no emails or phones, and no review authors.
    class ListingsController < BaseController
      PRELOADS = [ { property: [ :neighborhood, :amenities ] } ].freeze

      # GET /api/v1/listings?neighborhood_id=&max_rent=&available_from=&amenity_ids[]=
      # Only published listings, newest first.
      def index
        filters = search_filters
        return render_errors(@filter_errors, status: :bad_request) if @filter_errors.any?

        listings = Listing.search(filters).with_attached_photos.includes(*PRELOADS).newest_first
        render json: listings.map { |listing| listing_document(listing) }
      end

      # GET /api/v1/listings/:id
      # Drafts and withdrawn listings are not public: they answer 404 as if they did not exist.
      def show
        listing = ListingPolicy::Scope.new(nil, Listing).resolve.with_attached_photos.includes(*PRELOADS).find(params[:id])
        render json: listing_document(listing).merge(
          description: listing.description.to_plain_text,
          house_rules: listing.house_rules.to_plain_text
        )
      end

      private

      # Every filter is optional. A filter that is present but malformed answers 400 with the reason.
      def search_filters
        @filter_errors = []
        filters = {}

        if params[:neighborhood_id].present?
          if integer?(params[:neighborhood_id])
            filters[:neighborhood_id] = params[:neighborhood_id].to_i
          else
            @filter_errors << "neighborhood_id must be a whole number"
          end
        end

        if params[:max_rent].present?
          if integer?(params[:max_rent]) && params[:max_rent].to_i.positive?
            filters[:max_rent] = params[:max_rent].to_i
          else
            @filter_errors << "max_rent must be a positive whole number"
          end
        end

        if params[:available_from].present?
          if (date = iso_date(params[:available_from]))
            filters[:available_from] = date
          else
            @filter_errors << "available_from must be a date in the format YYYY-MM-DD"
          end
        end

        if params[:amenity_ids].present?
          ids = Array(params[:amenity_ids])
          if ids.all? { |id| integer?(id) }
            filters[:amenity_ids] = ids.map(&:to_i)
          else
            @filter_errors << "amenity_ids must be a list of whole numbers"
          end
        end

        filters
      end

      def iso_date(value)
        Date.iso8601(value.to_s)
      rescue Date::Error
        nil
      end

      def integer?(value)
        value.is_a?(String) && value.match?(/\A\d+\z/)
      end

      def listing_document(listing)
        property = listing.property
        {
          id: listing.id,
          title: listing.title,
          status: listing.status,
          monthly_rent: money(listing.monthly_rent),
          deposit: money(listing.deposit),
          available_on: listing.available_on.iso8601,
          minimum_stay_months: listing.minimum_stay_months,
          furnished: listing.furnished,
          private_bathroom: listing.private_bathroom,
          neighborhood: { id: property.neighborhood.id, name: property.neighborhood.name },
          property: {
            property_type: property.property_type,
            bedrooms_count: property.bedrooms_count,
            bathrooms_count: property.bathrooms_count,
            amenities: property.amenities.sort_by(&:name).map { |amenity| { id: amenity.id, name: amenity.name } }
          },
          photo_url: listing.cover_photo && url_for(listing.cover_photo.variant(:card)),
          url: listing_url(listing)
        }
      end
    end
  end
end
