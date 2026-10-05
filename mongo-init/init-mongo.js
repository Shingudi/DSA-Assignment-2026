// Namibia University of Science and Technology (NUST) - DSA612S
// Assignment 2: Distributed Food Delivery Platform
// MongoDB Initial Schema Setup & Data Seeding

db = db.getSiblingDB('food_delivery_db');

// Create collections


// Indexes for high concurrency & fast lookups
db.customers.createIndex({ "email": 1 }, { unique: true });
db.customers.createIndex({ "phone": 1 });
db.restaurants.createIndex({ "id": 1 }, { unique: true });
db.orders.createIndex({ "customerId": 1 });
db.orders.createIndex({ "restaurantId": 1 });
db.orders.createIndex({ "status": 1 });
db.orders.createIndex({ "createdAt": -1 });
db.deliveries.createIndex({ "driverId": 1 });
db.deliveries.createIndex({ "orderId": 1 }, { unique: true });

// Seed SME Restaurants
db.restaurants.insertMany([
  {
    id: "rest-001",
    name: "Kapana Corner & Grill (SME)",
    cuisine: "Traditional Namibian & Street Food",
    address: "Single Quarters, Katutura, Windhoek",
    latitude: -22.5312,
    longitude: 17.0543,
    isOpen: true,
    rating: 4.8,
    hours: { openTime: "09:00", closeTime: "22:30", isOpenToday: true },
    menu: [
      { id: "m-01", name: "Prime Beef Kapana Plate", category: "Beef", price: 65.0, inStock: true, stockQuantity: 45, description: "Charcoal flame-grilled spiced beef with chili dip & salsa" },
      { id: "m-02", name: "Vetkoek (Fat Cakes) x3", category: "Sides", price: 20.0, inStock: true, stockQuantity: 80, description: "Golden fluffy fried pastry dough" },
      { id: "m-03", name: "Traditional Oshikandela Drink", category: "Beverages", price: 18.0, inStock: true, stockQuantity: 30, description: "Chilled sour cultured milk drink" }
    ],
    createdAt: new Date()
  },
  {
    id: "rest-002",
    name: "Kalahari Flame Kitchen (SME)",
    cuisine: "Afro-Fusion & Braai",
    address: "Independence Avenue, Central Windhoek",
    latitude: -22.5697,
    longitude: 17.0832,
    isOpen: true,
    rating: 4.6,
    hours: { openTime: "11:00", closeTime: "21:00", isOpenToday: true },
    menu: [
      { id: "m-04", name: "Oryx Game Steak & Pap", category: "Game Meat", price: 120.0, inStock: true, stockQuantity: 15, description: "Tender Oryx sirloin with rich marrow gravy and maize meal" },
      { id: "m-05", name: "Morogo Spinach & Feta", category: "Vegetarian", price: 45.0, inStock: true, stockQuantity: 25, description: "Sautéed wild African greens with garlic and feta" }
    ],
    createdAt: new Date()
  },
  {
    id: "rest-003",
    name: "Etosha Safari Braai & Ribs (SME)",
    cuisine: "Wood-fired Barbeque",
    address: "Sam Nujoma Drive, Klein Windhoek",
    latitude: -22.5714,
    longitude: 17.1025,
    isOpen: true,
    rating: 4.7,
    hours: { openTime: "10:30", closeTime: "23:00", isOpenToday: true },
    menu: [
      { id: "m-06", name: "Namibian Lamb Chops (500g)", category: "Braai", price: 135.0, inStock: true, stockQuantity: 20, description: "Karoo-seasoned grass-fed lamb chops over camelthorn embers" },
      { id: "m-07", name: "Sweet Potato Roosterkoek", category: "Bread", price: 25.0, inStock: true, stockQuantity: 40, description: "Charcoal-baked grid bread with farm butter" }
    ],
    createdAt: new Date()
  }
]);

// Seed Registered Customer
db.customers.insertOne({
  id: "cust-001",
  name: "Lukas Shingudi",
  email: "shingudi.lukas@gmail.com",
  phone: "+264 81 234 5678",
  defaultAddress: {
    street: "13 Jackson Kaujeua Street",
    suburb: "Windhoek West",
    city: "Windhoek",
    latitude: -22.5609,
    longitude: 17.0658,
    instructions: "NUST Department of Software Engineering"
  },
  favoriteRestaurantIds: ["rest-001", "rest-002"],
  createdAt: new Date()
});

print("MongoDB: food_delivery_db initialized and seeded successfully for NUST Assignment 2.");
