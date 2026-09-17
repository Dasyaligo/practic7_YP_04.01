import '../models/phone.dart';
import '../models/brand.dart';
import '../models/customer.dart';
import '../models/loyalty_card.dart';
import '../models/order.dart';
import '../models/order_item.dart';

final seedBrands = [
  Brand(id: 1, name: 'Apple', country: 'USA', foundedYear: 1976),
  Brand(id: 2, name: 'Samsung', country: 'South Korea', foundedYear: 1938),
  Brand(id: 3, name: 'Xiaomi', country: 'China', foundedYear: 2010),
  Brand(id: 4, name: 'Google', country: 'USA', foundedYear: 1998),
  Brand(id: 5, name: 'OnePlus', country: 'China', foundedYear: 2013),
  Brand(id: 6, name: 'Sony', country: 'Japan', foundedYear: 1946),
  Brand(id: 7, name: 'Nokia', country: 'Finland', foundedYear: 1865),
  Brand(id: 8, name: 'Motorola', country: 'USA', foundedYear: 1928),
];

final seedPhones = [
  Phone(id: 1, model: 'iPhone 15 Pro', brandId: 1, price: 999.0, storage: 256, ram: 8, color: 'Титан', screenSize: 6.1, stock: 10, createdAt: DateTime(2023, 9, 15)),
  Phone(id: 2, model: 'iPhone 15 Pro Max', brandId: 1, price: 1199.0, storage: 512, ram: 8, color: 'Натуральный титан', screenSize: 6.7, stock: 5, createdAt: DateTime(2023, 9, 15)),
  Phone(id: 3, model: 'iPhone 15', brandId: 1, price: 799.0, storage: 128, ram: 6, color: 'Розовый', screenSize: 6.1, stock: 15, createdAt: DateTime(2023, 9, 15)),
  Phone(id: 4, model: 'Galaxy S24 Ultra', brandId: 2, price: 1299.0, storage: 512, ram: 12, color: 'Черный', screenSize: 6.8, stock: 8, createdAt: DateTime(2024, 1, 17)),
  Phone(id: 5, model: 'Galaxy S24+', brandId: 2, price: 1099.0, storage: 256, ram: 12, color: 'Серый', screenSize: 6.7, stock: 12, createdAt: DateTime(2024, 1, 17)),
  Phone(id: 6, model: 'Galaxy S24', brandId: 2, price: 799.0, storage: 128, ram: 8, color: 'Фиолетовый', screenSize: 6.2, stock: 20, createdAt: DateTime(2024, 1, 17)),
  Phone(id: 7, model: 'Mi 14 Pro', brandId: 3, price: 899.0, storage: 256, ram: 12, color: 'Черный', screenSize: 6.73, stock: 6, createdAt: DateTime(2023, 11, 1)),
  Phone(id: 8, model: 'Redmi Note 13 Pro', brandId: 3, price: 399.0, storage: 128, ram: 8, color: 'Зеленый', screenSize: 6.67, stock: 25, createdAt: DateTime(2024, 1, 15)),
  Phone(id: 9, model: 'Pixel 8 Pro', brandId: 4, price: 999.0, storage: 256, ram: 12, color: 'Obsidian', screenSize: 6.7, stock: 7, createdAt: DateTime(2023, 10, 4)),
  Phone(id: 10, model: 'Pixel 8', brandId: 4, price: 699.0, storage: 128, ram: 8, color: 'Hazel', screenSize: 6.2, stock: 14, createdAt: DateTime(2023, 10, 4)),
  Phone(id: 11, model: 'OnePlus 12', brandId: 5, price: 799.0, storage: 256, ram: 12, color: 'Flowy Emerald', screenSize: 6.82, stock: 9, createdAt: DateTime(2023, 12, 5)),
  Phone(id: 12, model: 'OnePlus 12R', brandId: 5, price: 599.0, storage: 128, ram: 8, color: 'Cool Blue', screenSize: 6.78, stock: 11, createdAt: DateTime(2024, 2, 6)),
  Phone(id: 13, model: 'iPhone SE (3rd)', brandId: 1, price: 429.0, storage: 64, ram: 4, color: 'Starlight', screenSize: 4.7, stock: 18, createdAt: DateTime(2022, 3, 18)),
  Phone(id: 14, model: 'Galaxy A55', brandId: 2, price: 449.0, storage: 128, ram: 8, color: 'Lilac', screenSize: 6.6, stock: 22, createdAt: DateTime(2024, 3, 11)),
  Phone(id: 15, model: 'Galaxy A35', brandId: 2, price: 399.0, storage: 128, ram: 6, color: 'Awesome Iceblue', screenSize: 6.6, stock: 16, createdAt: DateTime(2024, 3, 11)),
  Phone(id: 16, model: 'Xiaomi 13T Pro', brandId: 3, price: 699.0, storage: 256, ram: 12, color: 'Alpine Blue', screenSize: 6.67, stock: 4, createdAt: DateTime(2023, 9, 26)),
  Phone(id: 17, model: 'Pixel 7a', brandId: 4, price: 499.0, storage: 128, ram: 8, color: 'Charcoal', screenSize: 6.1, stock: 13, createdAt: DateTime(2023, 5, 10)),
  Phone(id: 18, model: 'OnePlus Nord 3', brandId: 5, price: 499.0, storage: 128, ram: 8, color: 'Misty Green', screenSize: 6.74, stock: 8, createdAt: DateTime(2023, 7, 5)),
  Phone(id: 19, model: 'iPhone 14', brandId: 1, price: 699.0, storage: 128, ram: 6, color: 'Blue', screenSize: 6.1, stock: 10, createdAt: DateTime(2022, 9, 7)),
  Phone(id: 20, model: 'Galaxy Z Fold5', brandId: 2, price: 1799.0, storage: 512, ram: 12, color: 'Phantom Black', screenSize: 7.6, stock: 3, createdAt: DateTime(2023, 8, 11)),
  Phone(id: 21, model: 'Xperia 1 V', brandId: 6, price: 1399.0, storage: 256, ram: 12, color: 'Black', screenSize: 6.5, stock: 2, createdAt: DateTime(2023, 5, 11)),
  Phone(id: 22, model: 'Xperia 5 V', brandId: 6, price: 999.0, storage: 128, ram: 8, color: 'White', screenSize: 6.1, stock: 4, createdAt: DateTime(2023, 9, 1)),
];

final seedCustomers = [
  Customer(id: 1, fullName: 'Иванов Иван Иванович', email: 'ivanov@mail.ru', phone: '+7 900 111-22-33', loyaltyCardId: 1, loyaltyPoints: 150, createdAt: DateTime(2025, 1, 15)),
  Customer(id: 2, fullName: 'Петрова Анна Сергеевна', email: 'petrova@mail.ru', phone: '+7 900 222-33-44', loyaltyCardId: 2, loyaltyPoints: 320, createdAt: DateTime(2025, 2, 20)),
  Customer(id: 3, fullName: 'Сидоров Петр Васильевич', email: 'sidorov@mail.ru', phone: '+7 900 333-44-55', loyaltyCardId: 3, loyaltyPoints: 50, createdAt: DateTime(2025, 3, 10)),
];

final seedLoyaltyCards = [
  LoyaltyCard(id: 1, customerId: 1, cardNumber: 'LC-0001', points: 150, issuedAt: DateTime(2025, 1, 15)),
  LoyaltyCard(id: 2, customerId: 2, cardNumber: 'LC-0002', points: 320, issuedAt: DateTime(2025, 2, 20)),
  LoyaltyCard(id: 3, customerId: 3, cardNumber: 'LC-0003', points: 50, issuedAt: DateTime(2025, 3, 10)),
];

final seedOrders = [
  Order(
    id: 1,
    customerId: 1,
    items: [
      OrderItem(id: 1, orderId: 1, phoneId: 1, quantity: 1, price: 999.0),
      OrderItem(id: 2, orderId: 1, phoneId: 3, quantity: 2, price: 799.0),
    ],
    orderDate: DateTime(2025, 1, 20),
    status: 'paid',
    total: 2597.0,
  ),
  Order(
    id: 2,
    customerId: 2,
    items: [
      OrderItem(id: 3, orderId: 2, phoneId: 4, quantity: 1, price: 1299.0),
    ],
    orderDate: DateTime(2025, 2, 25),
    status: 'shipped',
    total: 1299.0,
  ),
];