# Roomies sample data.
#
# Running `bin/rails db:seed` on an empty database leaves the application browsable. Running it again
# wipes the Roomies tables first, so it can be re-run at any time. Every date is relative to today, so
# the data stays coherent no matter when it is loaded: listings are created before they are applied to,
# applications before their visits, and visits before their reviews.

puts "Cleaning up..."
[ Report, SavedListing, Review, Visit, Application, Listing,
  PropertyAmenity, Property, Amenity, Neighborhood, User ].each(&:destroy_all)

# Photographs live in db/seeds/photos and are attached through Active Storage.
PHOTOS_DIR = Rails.root.join("db/seeds/photos")

def add_photos(listing, *keys)
  keys.each do |key, _caption|
    listing.photos.attach(io: PHOTOS_DIR.join("#{key}.jpg").open, filename: "#{key}.jpg", content_type: "image/jpeg")
  end
end

today = Date.current

# --- Users -------------------------------------------------------------------------------------------

puts "Creating users..."
users = {}
[
  [ :andrea, "Andrea Fuentes", "andrea.fuentes@roomies.cl", "+56 9 6123 4501", :moderator ],
  [ :ignacio, "Ignacio Pérez", "ignacio.perez@roomies.cl", "+56 9 6123 4502", :moderator ],
  [ :camila, "Camila Rojas", "camila.rojas@gmail.com", "+56 9 8812 3301", :member ],
  [ :matias, "Matías González", "matias.gonzalez@gmail.com", "+56 9 7734 1182", :member ],
  [ :valentina, "Valentina Muñoz", "vale.munoz@outlook.com", "+56 9 9921 0473", :member ],
  [ :benjamin, "Benjamín Soto", "benja.soto@gmail.com", "+56 9 5547 8820", :member ],
  [ :javiera, "Javiera Contreras", "javiera.contreras@gmail.com", "+56 9 6688 2915", :member ],
  [ :diego, "Diego Silva", "diego.silva@uc.cl", "+56 9 7310 5546", :member ],
  [ :sofia, "Sofía Morales", "sofia.morales@miuandes.cl", "+56 9 8455 7712", :member ],
  [ :joaquin, "Joaquín Castillo", "joaquin.castillo@gmail.com", "+56 9 9012 3368", :member ],
  [ :martina, "Martina Herrera", "martina.herrera@udd.cl", "+56 9 6201 9984", :member ],
  [ :felipe, "Felipe Vargas", "felipe.vargas@gmail.com", "+56 9 7765 4431", :member ],
  [ :isidora, "Isidora Reyes", "isidora.reyes@uchile.cl", "+56 9 8340 2276", :member ],
  [ :nicolas, "Nicolás Espinoza", "nico.espinoza@gmail.com", "+56 9 5098 1123", :member ],
  [ :antonia, "Antonia Díaz", "antonia.diaz@outlook.com", "+56 9 9187 6640", :member ],
  [ :sebastian, "Sebastián Torres", "seba.torres@gmail.com", "+56 9 6672 0058", :member ],
  [ :florencia, "Florencia Navarro", "flo.navarro@gmail.com", "+56 9 7429 3317", :member ],
  [ :lucas, "Lucas Paredes", "lucas.paredes@usach.cl", "+56 9 8873 5509", :member ]
].each do |key, name, email, phone, role|
  users[key] = User.create!(name: name, email: email, phone: phone, role: role, created_at: 9.months.ago)
end

# --- Catalogs ----------------------------------------------------------------------------------------

puts "Creating neighborhoods and amenities..."
neighborhoods = [
  "Providencia", "Ñuñoa", "Las Condes", "Santiago Centro", "Vitacura",
  "La Reina", "San Miguel", "Macul", "Independencia", "Estación Central"
].index_with { |name| Neighborhood.create!(name: name) }

amenities = [
  "Wi-Fi", "Washing machine", "Parking", "Elevator", "Pets allowed", "Balcony", "Air conditioning",
  "Central heating", "Gym", "Swimming pool", "24h concierge", "Bike storage", "Dishwasher"
].index_with { |name| Amenity.create!(name: name) }

# --- Properties --------------------------------------------------------------------------------------

puts "Creating properties..."
def create_property(host:, neighborhood:, amenities:, **attributes)
  property = Property.create!(host: host, neighborhood: neighborhood, created_at: 8.months.ago, **attributes)
  property.amenities = amenities
  property
end

providencia_apartment = create_property(
  host: users[:camila], neighborhood: neighborhoods["Providencia"],
  address: "Av. Providencia 1650, depto. 1204", property_type: "apartment",
  bedrooms_count: 3, bathrooms_count: 2,
  shared_spaces_description: "Open living and dining room with a balcony facing the Andes, a fully equipped " \
                             "kitchen and a laundry corner. Two blocks from Pedro de Valdivia metro station.",
  amenities: amenities.values_at("Wi-Fi", "Washing machine", "Elevator", "24h concierge", "Balcony")
)

nunoa_house = create_property(
  host: users[:matias], neighborhood: neighborhoods["Ñuñoa"],
  address: "Av. Irarrázaval 3450", property_type: "house",
  bedrooms_count: 4, bathrooms_count: 2,
  shared_spaces_description: "Two-storey house with a backyard and a barbecue area, a large kitchen, a living " \
                             "room with a fireplace and a covered space for bikes. Close to Plaza Ñuñoa.",
  amenities: amenities.values_at("Wi-Fi", "Washing machine", "Pets allowed", "Bike storage", "Central heating")
)

las_condes_apartment = create_property(
  host: users[:valentina], neighborhood: neighborhoods["Las Condes"],
  address: "Av. Apoquindo 4500, depto. 803", property_type: "apartment",
  bedrooms_count: 3, bathrooms_count: 2,
  shared_spaces_description: "Modern apartment in a building with a gym, a rooftop pool and 24-hour concierge. " \
                             "Shared living room, kitchen with dishwasher and a covered parking spot.",
  amenities: amenities.values_at("Wi-Fi", "Gym", "Swimming pool", "Elevator", "Parking", "Air conditioning",
                                 "24h concierge")
)

lastarria_apartment = create_property(
  host: users[:benjamin], neighborhood: neighborhoods["Santiago Centro"],
  address: "José Victorino Lastarria 210, depto. 52", property_type: "apartment",
  bedrooms_count: 2, bathrooms_count: 1,
  shared_spaces_description: "Classic building in barrio Lastarria, high ceilings and wooden floors. Shared " \
                             "living room, small kitchen and a laundry area. Walking distance to Universidad Católica metro.",
  amenities: amenities.values_at("Wi-Fi", "Elevator", "Washing machine")
)

la_reina_house = create_property(
  host: users[:javiera], neighborhood: neighborhoods["La Reina"],
  address: "Los Aromos 1380", property_type: "house",
  bedrooms_count: 4, bathrooms_count: 3,
  shared_spaces_description: "Quiet family house with a big garden, a terrace, a separate laundry room and a " \
                             "kitchen with a dishwasher. Two dogs live in the house.",
  amenities: amenities.values_at("Wi-Fi", "Parking", "Pets allowed", "Washing machine", "Central heating",
                                 "Dishwasher")
)

vitacura_apartment = create_property(
  host: users[:diego], neighborhood: neighborhoods["Vitacura"],
  address: "Av. Vitacura 3200, depto. 1501", property_type: "apartment",
  bedrooms_count: 2, bathrooms_count: 2,
  shared_spaces_description: "Fifteenth-floor apartment with a view of the city, an open-plan kitchen and " \
                             "living room, and access to the building's gym and pool.",
  amenities: amenities.values_at("Wi-Fi", "Gym", "Swimming pool", "Parking", "24h concierge",
                                 "Air conditioning", "Dishwasher")
)

san_miguel_townhouse = create_property(
  host: users[:camila], neighborhood: neighborhoods["San Miguel"],
  address: "Gran Avenida José Miguel Carrera 4200, casa 7", property_type: "townhouse",
  bedrooms_count: 3, bathrooms_count: 2,
  shared_spaces_description: "Townhouse in a gated condominium with a small patio, a shared living room and a " \
                             "kitchen. Five minutes from El Llano metro station.",
  amenities: amenities.values_at("Wi-Fi", "Washing machine", "Bike storage", "Pets allowed")
)

independencia_apartment = create_property(
  host: users[:matias], neighborhood: neighborhoods["Independencia"],
  address: "Av. Independencia 980, depto. 302", property_type: "apartment",
  bedrooms_count: 2, bathrooms_count: 1,
  shared_spaces_description: "Simple apartment near Hospital Clínico and the Universidad de Chile medical campus.",
  amenities: amenities.values_at("Wi-Fi", "Elevator")
)

macul_house = create_property(
  host: users[:valentina], neighborhood: neighborhoods["Macul"],
  address: "Av. Macul 2800", property_type: "house",
  bedrooms_count: 3, bathrooms_count: 1,
  shared_spaces_description: "One-storey house with a front yard, a shared kitchen and living room. Close to " \
                             "Campus San Joaquín.",
  amenities: amenities.values_at("Wi-Fi", "Washing machine", "Parking", "Bike storage")
)

# --- Listings ----------------------------------------------------------------------------------------
# Every listing is created as a draft and published right away (unless it stays a draft), receives its applications, and only then moves along its
# lifecycle, exactly as it would in the application.

puts "Creating listings..."
def create_listing(property:, created:, available:, status: :published, **attributes)
  listing = Listing.create!(property: property, created_at: created, available_on: available, **attributes)
  listing.update!(status: :published) if status.to_s == "published"
  listing
end

l_providencia_suite = create_listing(
  property: providencia_apartment, created: 10.days.ago, available: today + 20,
  title: "Bright room with private bathroom near Pedro de Valdivia",
  monthly_rent: 430_000, deposit: 430_000, minimum_stay_months: 6, furnished: true, private_bathroom: true,
  description: "The largest bedroom in the apartment, with a double bed, a desk and its own bathroom. " \
               "You would share the flat with me (Camila, 29, architect) and Pedro, a PhD student.",
  house_rules: "<ul><li><strong>Quiet hours</strong> from 23:00 to 8:00</li><li>No smoking indoors</li>" \
               "<li>We split cleaning every week</li></ul>"
)
add_photos(l_providencia_suite, [ :bedroom_hotel, "Bedroom" ], [ :bathroom_modern, "Private bathroom" ],
           [ :living_bright, "Living room" ], [ :kitchen_white, "Kitchen" ])

l_providencia_small = create_listing(
  property: providencia_apartment, created: 70.days.ago, available: today - 55,
  title: "Cozy single room in Providencia",
  monthly_rent: 360_000, deposit: 360_000, minimum_stay_months: 6, furnished: true,
  description: "Single room with a wardrobe and a window to the inner courtyard. Shared bathroom with one person. " \
               "Ideal for a student or a young professional."
)
add_photos(l_providencia_small, [ :bedroom_white, "Bedroom" ], [ :living_bright, "Living room" ])

l_providencia_old = create_listing(
  property: providencia_apartment, created: 7.months.ago, available: today - 195,
  title: "Furnished room with balcony access",
  monthly_rent: 390_000, deposit: 390_000, minimum_stay_months: 12, furnished: true,
  description: "Medium-sized room next to the balcony, furnished with a queen bed and a desk."
)
add_photos(l_providencia_old, [ :bedroom_cozy, "Bedroom" ], [ :living_view, "Living room at sunset" ])

l_nunoa_garden = create_listing(
  property: nunoa_house, created: 40.days.ago, available: today + 5,
  title: "Room overlooking the garden in Ñuñoa",
  monthly_rent: 320_000, deposit: 320_000, minimum_stay_months: 3, furnished: false,
  description: "Spacious unfurnished room on the ground floor with a big window to the backyard. " \
               "We are three housemates (two engineers and a musician) and a very friendly cat. " \
               "We cook together on Sundays. Pets are welcome.",
  house_rules: "<p><em>Pets are welcome</em>, as long as they get along with our cat.</p>" \
               "<ul><li>Guests are fine, just let the house know</li><li>Shared groceries are split every month</li></ul>"
)
add_photos(l_nunoa_garden, [ :bedroom_plants, "Bedroom" ], [ :living_plants, "Living room" ],
           [ :dining, "Dining area" ], [ :house_garden, "Backyard" ])

l_nunoa_attic = create_listing(
  property: nunoa_house, created: 12.days.ago, available: today + 30,
  title: "Attic room with skylight, Plaza Ñuñoa",
  monthly_rent: 290_000, deposit: 290_000, minimum_stay_months: 3, furnished: true,
  description: "Second-floor attic room with a skylight, a single bed and lots of storage. " \
               "Shared bathroom on the same floor."
)
add_photos(l_nunoa_attic, [ :bedroom_wood, "Bedroom" ], [ :living_plants, "Living room" ])

l_nunoa_draft = create_listing(
  property: nunoa_house, created: 2.days.ago, available: today + 60, status: :draft,
  title: "Small room next to the kitchen (draft)",
  monthly_rent: 250_000, deposit: 250_000, minimum_stay_months: 6,
  description: "Still writing this one — photos coming soon."
)

l_las_condes = create_listing(
  property: las_condes_apartment, created: 25.days.ago, available: today + 10,
  title: "Furnished room in Apoquindo with gym and pool",
  monthly_rent: 495_000, deposit: 495_000, minimum_stay_months: 6, furnished: true, private_bathroom: true,
  description: "Room with a double bed, air conditioning and a private bathroom, in a building with a gym and " \
               "a rooftop pool. Five minutes from Escuela Militar metro. Shared with two professionals."
)
add_photos(l_las_condes, [ :bedroom_dark, "Bedroom" ], [ :living_minimal, "Living room" ],
           [ :kitchen_marble, "Kitchen" ])

l_las_condes_old = create_listing(
  property: las_condes_apartment, created: 5.months.ago, available: today - 130,
  title: "Room with walk-in closet in Las Condes",
  monthly_rent: 470_000, deposit: 470_000, minimum_stay_months: 12, furnished: true,
  description: "Large room with a walk-in closet and a view of Cerro Manquehue."
)
add_photos(l_las_condes_old, [ :bedroom_grey, "Bedroom" ], [ :living_minimal, "Living room" ])

l_lastarria = create_listing(
  property: lastarria_apartment, created: 18.days.ago, available: today,
  title: "Room in barrio Lastarria, steps from the metro",
  monthly_rent: 275_000, deposit: 275_000, minimum_stay_months: 3, furnished: true,
  description: "Single room with high ceilings in a classic building. You would live with Benjamín, a chef " \
               "who works evenings. Great for someone who enjoys cafés, museums and walking everywhere."
)
add_photos(l_lastarria, [ :bedroom_orange, "Bedroom" ], [ :living_yellow, "Living room" ])

l_lastarria_flagged = create_listing(
  property: lastarria_apartment, created: 35.days.ago, available: today - 20,
  title: "HUGE room downtown, all bills included!!!",
  monthly_rent: 150_000, deposit: 600_000, minimum_stay_months: 1,
  description: "Transfer the deposit today to secure the room. Visits are not possible."
)

l_la_reina = create_listing(
  property: la_reina_house, created: 15.days.ago, available: today + 14,
  title: "Quiet room in a family house with garden",
  monthly_rent: 340_000, deposit: 340_000, minimum_stay_months: 6, furnished: true,
  description: "Calm, sunny room in a house with a big garden. I live here with my partner and our two dogs. " \
               "Perfect for someone who works from home and loves animals.",
  house_rules: "<ol><li>No parties</li><li><strong>The dogs stay out of the bedrooms</strong></li>" \
               "<li>Garden and terrace are shared by everyone</li></ol>"
)
add_photos(l_la_reina, [ :bedroom_cozy, "Bedroom" ], [ :living_classic, "Living room" ],
           [ :house_garden, "Garden" ], [ :bathroom_small, "Bathroom" ])

l_la_reina_suite = create_listing(
  property: la_reina_house, created: 45.days.ago, available: today - 10,
  title: "En-suite room with terrace in La Reina",
  monthly_rent: 360_000, deposit: 360_000, minimum_stay_months: 6, furnished: true, private_bathroom: true,
  description: "En-suite room with direct access to the terrace."
)
add_photos(l_la_reina_suite, [ :bedroom_hotel, "Bedroom" ], [ :bathroom_modern, "En-suite bathroom" ])

l_vitacura = create_listing(
  property: vitacura_apartment, created: 8.days.ago, available: today + 25,
  title: "Room with city view in Vitacura",
  monthly_rent: 550_000, deposit: 550_000, minimum_stay_months: 12, furnished: true, private_bathroom: true,
  description: "Fifteenth-floor room with floor-to-ceiling windows. I'm moving for an exchange semester and " \
               "renting my room while I'm away — you would share with Rodrigo, a lawyer."
)
add_photos(l_vitacura, [ :bedroom_grey, "Bedroom" ], [ :living_view, "Living room" ], [ :living_open, "Kitchen and dining" ])

l_san_miguel = create_listing(
  property: san_miguel_townhouse, created: 6.days.ago, available: today + 15,
  title: "Affordable room near El Llano metro",
  monthly_rent: 250_000, deposit: 250_000, minimum_stay_months: 3,
  description: "Simple and bright room in a gated townhouse. Shared with two university students."
)
add_photos(l_san_miguel, [ :bedroom_white, "Bedroom" ], [ :living_blue, "Living room" ])

create_listing(
  property: san_miguel_townhouse, created: 1.day.ago, available: today + 45, status: :draft,
  title: "Second room in San Miguel townhouse",
  monthly_rent: 240_000, deposit: 240_000, minimum_stay_months: 3,
  description: "Draft — waiting for the current tenant to confirm the move-out date."
)

l_independencia = create_listing(
  property: independencia_apartment, created: 50.days.ago, available: today - 40,
  title: "Room for a medical student in Independencia",
  monthly_rent: 220_000, deposit: 220_000, minimum_stay_months: 6,
  description: "Room five minutes from Hospital Clínico. Taken down: the owner decided to sell the apartment."
)
add_photos(l_independencia, [ :bedroom_white, "Bedroom" ])

l_macul = create_listing(
  property: macul_house, created: 4.days.ago, available: today + 7,
  title: "Student room near Campus San Joaquín",
  monthly_rent: 230_000, deposit: 230_000, minimum_stay_months: 5, furnished: true,
  description: "Furnished room in a quiet house, a ten-minute walk from Campus San Joaquín. Bills split equally."
)
add_photos(l_macul, [ :bedroom_plants, "Bedroom" ], [ :living_blue, "Living room" ], [ :kitchen_white, "Kitchen" ])

# --- Applications, visits and reviews ---------------------------------------------------------------

puts "Creating applications, visits and reviews..."
def apply(listing, seeker, sent:, status: :pending, move_in: nil, months: nil, message:)
  Application.create!(
    listing: listing, seeker: seeker, status: status, created_at: sent,
    move_in_date: move_in || [ listing.available_on, sent.to_date ].max + 7,
    stay_duration_months: months || [ listing.minimum_stay_months, 6 ].max,
    message: message
  )
end

def visit(application, at:, status:)
  application.visits.create!(scheduled_at: at, status: status, created_at: application.created_at + 1.day)
end

def review(visit, rating:, comment:, written:)
  Review.create!(visit: visit, rating: rating, comment: comment, created_at: written)
end

# Ñuñoa garden room: five people competing for the same room, one in every open-or-closed state.
apply(l_nunoa_garden, users[:sofia], sent: 3.days.ago,
      message: "Hi! I'm Sofía, I study engineering at Universidad de los Andes and I'm looking for a calm " \
               "place close to the metro. I have a small cat, very well behaved.")
joaquin_nunoa = apply(l_nunoa_garden, users[:joaquin], sent: 20.days.ago, status: :shortlisted,
                      message: "Hello Matías, I'm a software developer working remotely. I play the guitar " \
                               "(quietly, I promise) and would love to join the Sunday dinners.")
visit(joaquin_nunoa, at: 2.days.from_now.change(hour: 19), status: :confirmed)
martina_nunoa = apply(l_nunoa_garden, users[:martina], sent: 30.days.ago, status: :shortlisted,
                      message: "Hi, I'm Martina, a psychology student. I'm tidy, I like plants and I'm looking " \
                               "for a long-term place.")
martina_visit = visit(martina_nunoa, at: 22.days.ago.change(hour: 18), status: :completed)
review(martina_visit, rating: 5, written: 21.days.ago,
       comment: "Exactly like the photos. The backyard is lovely and the housemates were very welcoming.")
apply(l_nunoa_garden, users[:felipe], sent: 28.days.ago, status: :rejected,
      message: "Hi, I'm Felipe. I work shifts at a hospital, so I'm hardly ever home.")
apply(l_nunoa_garden, users[:isidora], sent: 25.days.ago, status: :withdrawn,
      message: "Hello! I'm Isidora, a law student at Universidad de Chile.")

# Providencia single room: accepted application, every other one rejected, listing reserved.
nicolas_prov = apply(l_providencia_small, users[:nicolas], sent: 60.days.ago, status: :shortlisted,
                     message: "Hi Camila, I'm Nicolás, I just started a job in Providencia and want to walk to work.")
nicolas_visit = visit(nicolas_prov, at: 55.days.ago.change(hour: 17), status: :completed)
review(nicolas_visit, rating: 4, written: 54.days.ago,
       comment: "Great location and a very well kept apartment. The room is smaller than it looks in the photos.")
antonia_prov = apply(l_providencia_small, users[:antonia], sent: 58.days.ago, status: :shortlisted,
                     message: "Hello! I'm Antonia, a graphic designer. I work from home most days.")
visit(antonia_prov, at: 54.days.ago.change(hour: 12), status: :cancelled)
apply(l_providencia_small, users[:sebastian], sent: 57.days.ago,
      message: "Hi, I'm Sebastián, a business student looking for a room for the semester.")
apply(l_providencia_small, users[:florencia], sent: 59.days.ago, status: :withdrawn,
      message: "Hi Camila! I'm Florencia, I'm moving from Concepción for work.")
nicolas_prov.accept || raise("could not accept nicolas_prov")

# Providencia balcony room: rented months ago.
lucas_prov = apply(l_providencia_old, users[:lucas], sent: 6.months.ago, status: :shortlisted,
                   message: "Hi! I'm Lucas, a teacher. I'm looking for a long-term room close to the metro.")
lucas_visit = visit(lucas_prov, at: (6.months.ago + 4.days).change(hour: 18), status: :completed)
review(lucas_visit, rating: 5, written: 6.months.ago + 5.days,
       comment: "Camila is a fantastic host and the balcony view is even better in person.")
apply(l_providencia_old, users[:sofia], sent: 6.months.ago + 1.day,
      message: "Hi, I'm Sofía. I'm interested in the room for next semester.")
lucas_prov.accept || raise("could not accept lucas_prov")
l_providencia_old.rented!

# Las Condes walk-in closet room: rented.
flo_lc = apply(l_las_condes_old, users[:florencia], sent: 4.months.ago, status: :shortlisted,
               message: "Hello Valentina, I'm Florencia, an accountant at a firm on Apoquindo.")
flo_visit = visit(flo_lc, at: (4.months.ago + 3.days).change(hour: 19), status: :completed)
review(flo_visit, rating: 4, written: 4.months.ago + 4.days,
       comment: "Very modern building and the gym is great. Parking is tight but it works.")
apply(l_las_condes_old, users[:felipe], sent: 4.months.ago + 2.days,
      message: "Hi, I'm Felipe. Would love to live close to my work.")
flo_lc.accept || raise("could not accept flo_lc")
l_las_condes_old.rented!

# La Reina en-suite room: reserved.
antonia_lr = apply(l_la_reina_suite, users[:antonia], sent: 40.days.ago, status: :shortlisted,
                   message: "Hi Javiera! I'm Antonia, I work from home and I adore dogs.")
antonia_visit = visit(antonia_lr, at: 36.days.ago.change(hour: 11), status: :completed)
review(antonia_visit, rating: 5, written: 35.days.ago,
       comment: "Peaceful, sunny and the dogs are adorable. The terrace is perfect for working outside.")
seba_lr = apply(l_la_reina_suite, users[:sebastian], sent: 38.days.ago, status: :shortlisted,
                message: "Hello, I'm Sebastián. I'm looking for a quieter neighborhood to study.")
visit(seba_lr, at: 34.days.ago.change(hour: 18), status: :completed)
antonia_lr.accept || raise("could not accept antonia_lr")

# Providencia suite: a host acting as a seeker, plus a rescheduled visit.
apply(l_providencia_suite, users[:diego], sent: 2.days.ago,
      message: "Hi Camila, I'm Diego. I'm renting out my own room in Vitacura while I'm on exchange, but " \
               "I'll be back in Santiago for a few months first and need a place in Providencia.")
isidora_prov = apply(l_providencia_suite, users[:isidora], sent: 8.days.ago, status: :shortlisted,
                     message: "Hello Camila! I'm Isidora, a law student. I'm quiet, organized and non-smoking.")
visit(isidora_prov, at: 4.days.ago.change(hour: 16), status: :cancelled)
visit(isidora_prov, at: 3.days.from_now.change(hour: 18), status: :proposed)

# Las Condes room: a completed visit that did not end in an acceptance (yet).
apply(l_las_condes, users[:sebastian], sent: 5.days.ago,
      message: "Hi Valentina, I'm Sebastián. I'd like to be closer to my internship in El Golf.")
felipe_lc = apply(l_las_condes, users[:felipe], sent: 20.days.ago, status: :shortlisted,
                  message: "Hi again Valentina! Felipe here, I applied to your other room a few months ago.")
felipe_visit = visit(felipe_lc, at: 15.days.ago.change(hour: 20), status: :completed)
review(felipe_visit, rating: 3, written: 14.days.ago,
       comment: "Nice building, but the room gets very hot in the afternoon and the AC is noisy.")

apply(l_lastarria, users[:sofia], sent: 6.days.ago,
      message: "Hi Benjamín, I'm Sofía. I love the neighborhood and I'd be home mostly on weekdays.")
apply(l_vitacura, users[:martina], sent: 3.days.ago,
      message: "Hello Diego! The view looks amazing. I'm a tidy psychology student looking for a year-long stay.")
apply(l_la_reina, users[:isidora], sent: 4.days.ago,
      message: "Hi Javiera, I'm Isidora. I grew up with dogs and I'd love to live in a house with a garden.")

# Flagged listing: reported, then taken down by a moderator — pending applications are voided.
joaquin_flagged = apply(l_lastarria_flagged, users[:joaquin], sent: 30.days.ago,
                        message: "Hi, is the room still available? Can I visit before paying the deposit?")
joaquin_flagged.rejected!
l_lastarria_flagged.withdrawn!

# Independencia room: withdrawn by its host.
nico_ind = apply(l_independencia, users[:nicolas], sent: 45.days.ago,
                 message: "Hi Matías, is the room still available?")
nico_ind.rejected!
l_independencia.withdrawn!

# --- Saved listings and reports ----------------------------------------------------------------------

puts "Creating saved listings and reports..."
[
  [ :sofia, l_nunoa_garden ], [ :sofia, l_lastarria ], [ :sofia, l_macul ],
  [ :joaquin, l_nunoa_garden ], [ :joaquin, l_vitacura ],
  [ :martina, l_vitacura ], [ :martina, l_la_reina ],
  [ :isidora, l_providencia_suite ], [ :isidora, l_la_reina ], [ :isidora, l_san_miguel ],
  [ :sebastian, l_las_condes ], [ :lucas, l_nunoa_attic ], [ :diego, l_providencia_suite ]
].each do |seeker, listing|
  SavedListing.create!(seeker: users[seeker], listing: listing, created_at: 2.days.ago)
end

Report.create!(listing: l_lastarria_flagged, reporter: users[:joaquin], reason: "fraudulent", status: :resolved,
               resolved_by: users[:andrea], created_at: 29.days.ago,
               details: "The host asks for the deposit by bank transfer before any visit and the rent is far too low.")
Report.create!(listing: l_lastarria_flagged, reporter: users[:sofia], reason: "misleading", status: :resolved,
               resolved_by: users[:andrea], created_at: 28.days.ago,
               details: "The photos were taken from another website.")
Report.create!(listing: l_las_condes, reporter: users[:lucas], reason: "misleading", status: :dismissed,
               resolved_by: users[:ignacio], created_at: 10.days.ago,
               details: "I don't think the building really has a pool.")
Report.create!(listing: l_vitacura, reporter: users[:felipe], reason: "other", status: :pending,
               created_at: 1.day.ago,
               details: "The rent seems very high for a shared room, maybe it's a typo?")

puts "Done!"
[ User, Neighborhood, Amenity, Property, PropertyAmenity, Listing, ActiveStorage::Attachment,
  Application, Visit, Review, SavedListing, Report ].each do |model|
  puts "  #{model.name.pluralize.ljust(18)} #{model.count}"
end
