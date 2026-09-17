'use strict';

const http = require('node:http');
const crypto = require('node:crypto');

const args = process.argv.slice(2);
function arg(name, fallback) {
  const i = args.indexOf('--' + name);
  return i !== -1 && args[i + 1] ? args[i + 1] : fallback;
}

const PORT = Number(arg('port', 8080));
const ORIGIN = arg('origin', '*');
const ACCESS_TTL = Number(arg('ttl', 900));

let db = {};
let seq = {};

function seed() {
  db = {
    phones: [], brands: [], customers: [], loyaltyCards: [], orders: [], orderItems: [],
    accessories: [], reviews: [], employees: [],
    users: [], sessions: {},
  };
  seq = {
    phones: 0, brands: 0, customers: 0, loyaltyCards: 0, orders: 0, orderItems: 0,
    accessories: 0, reviews: 0, employees: 0, users: 0,
  };

  // ─── BRANDS ───
  const apple = addBrand('Apple', 'USA', 1976);
  const samsung = addBrand('Samsung', 'South Korea', 1938);
  const xiaomi = addBrand('Xiaomi', 'China', 2010);
  const google = addBrand('Google', 'USA', 1998);
  const oneplus = addBrand('OnePlus', 'China', 2013);
  const sony = addBrand('Sony', 'Japan', 1946);
  addBrand('Nokia', 'Finland', 1865);
  addBrand('Motorola', 'USA', 1928);

  // ─── PHONES ───
  addPhone('iPhone 15 Pro', apple.id, 999, 256, 8, 'Титан', 6.1, 10);
  addPhone('iPhone 15 Pro Max', apple.id, 1199, 512, 8, 'Натуральный титан', 6.7, 5);
  addPhone('iPhone 15', apple.id, 799, 128, 6, 'Розовый', 6.1, 15);
  addPhone('Galaxy S24 Ultra', samsung.id, 1299, 512, 12, 'Черный', 6.8, 8);
  addPhone('Galaxy S24+', samsung.id, 1099, 256, 12, 'Серый', 6.7, 12);
  addPhone('Galaxy S24', samsung.id, 799, 128, 8, 'Фиолетовый', 6.2, 20);
  addPhone('Mi 14 Pro', xiaomi.id, 899, 256, 12, 'Черный', 6.73, 6);
  addPhone('Redmi Note 13 Pro', xiaomi.id, 399, 128, 8, 'Зеленый', 6.67, 25);
  addPhone('Pixel 8 Pro', google.id, 999, 256, 12, 'Obsidian', 6.7, 7);
  addPhone('Pixel 8', google.id, 699, 128, 8, 'Hazel', 6.2, 14);
  addPhone('OnePlus 12', oneplus.id, 799, 256, 12, 'Flowy Emerald', 6.82, 9);
  addPhone('OnePlus 12R', oneplus.id, 599, 128, 8, 'Cool Blue', 6.78, 11);
  addPhone('iPhone SE (3rd)', apple.id, 429, 64, 4, 'Starlight', 4.7, 18);
  addPhone('Xperia 1 V', sony.id, 1399, 256, 12, 'Black', 6.5, 2);
  addPhone('Xperia 5 V', sony.id, 999, 128, 8, 'White', 6.1, 4);

  // ─── CUSTOMERS ───
  const c1 = addCustomer('Иванов Иван Иванович', 'ivanov@mail.ru', '+7 900 111-22-33');
  const c2 = addCustomer('Петрова Анна Сергеевна', 'petrova@mail.ru', '+7 900 222-33-44');
  const c3 = addCustomer('Сидоров Петр Васильевич', 'sidorov@mail.ru', '+7 900 333-44-55');

  addLoyaltyCard(c1.id, 'LC-0001', 150);
  addLoyaltyCard(c2.id, 'LC-0002', 320);
  addLoyaltyCard(c3.id, 'LC-0003', 50);

  // ─── ORDERS ───
  addOrder(c1.id, [{ phoneId: 1, quantity: 1, price: 999 }, { phoneId: 3, quantity: 2, price: 799 }], 'paid', 2597);
  addOrder(c2.id, [{ phoneId: 4, quantity: 1, price: 1299 }], 'shipped', 1299);

  // ─── ACCESSORIES ───
  addAccessory('Чехол силиконовый', 'Защита', 1500, 'Мягкий чехол для iPhone');
  addAccessory('Зарядка USB-C 30W', 'Питание', 2500, 'Быстрая зарядка');
  addAccessory('Наушники TWS', 'Аудио', 5000, 'Беспроводные наушники');
  addAccessory('Защитное стекло', 'Защита', 800, 'Упрочнённое стекло');
  addAccessory('Powerbank 20000 mAh', 'Питание', 3500, 'Ёмкий аккумулятор');

  // ─── EMPLOYEES ───
  addEmployee('Сидоров Пётр Иванович', 'Менеджер', 'sidorov@onlyphones.local', 70000);
  addEmployee('Кузнецова Ольга Сергеевна', 'Продавец', 'kuznetsova@onlyphones.local', 55000);
  addEmployee('Морозов Дмитрий Александрович', 'Курьер', 'morozov@onlyphones.local', 45000);

  // ─── REVIEWS ───
  addReview(c1.id, 1, 5, 'Отличный телефон, всё летает!');
  addReview(c2.id, 4, 4, 'Хорошая камера, но батарея могла быть лучше');
  addReview(c3.id, 1, 5, 'Довольна покупкой, спасибо!');

  // ─── USERS ───
  addUser('admin', 'admin123', 'Администратор', 'admin@onlyphones.local', 'admin', null);
  addUser('manager', 'manager123', 'Менеджер Петров', 'manager@onlyphones.local', 'manager', null);
  addUser('customer', 'customer123', 'Иванов Иван', 'customer@onlyphones.local', 'customer', c1.id);
}

function addBrand(name, country, foundedYear) {
  const id = ++seq.brands;
  db.brands.push({ id, name, country, foundedYear, createdAt: new Date().toISOString(), deletedAt: null });
  return db.brands[db.brands.length - 1];
}

function addPhone(model, brandId, price, storage, ram, color, screenSize, stock) {
  const id = ++seq.phones;
  db.phones.push({ id, model, brandId, price, storage, ram, color, screenSize, stock, createdAt: new Date().toISOString(), deletedAt: null });
  return db.phones[db.phones.length - 1];
}

function addCustomer(fullName, email, phone) {
  const id = ++seq.customers;
  db.customers.push({ id, fullName, email, phone, loyaltyCardId: null, loyaltyPoints: 0, createdAt: new Date().toISOString(), deletedAt: null });
  return db.customers[db.customers.length - 1];
}

function addLoyaltyCard(customerId, cardNumber, points) {
  const id = ++seq.loyaltyCards;
  db.loyaltyCards.push({ id, customerId, cardNumber, points, issuedAt: new Date().toISOString(), expiresAt: null, deletedAt: null });
  const customer = db.customers.find(c => c.id === customerId);
  if (customer) { customer.loyaltyCardId = id; customer.loyaltyPoints = points; }
  return db.loyaltyCards[db.loyaltyCards.length - 1];
}

function addOrder(customerId, items, status, total) {
  const id = ++seq.orders;
  db.orders.push({ id, customerId, orderDate: new Date().toISOString(), status, total, deletedAt: null });
  for (const item of items) {
    const itemId = ++seq.orderItems;
    db.orderItems.push({ id: itemId, orderId: id, phoneId: item.phoneId, quantity: item.quantity, price: item.price, deletedAt: null });
  }
  return db.orders[db.orders.length - 1];
}

function addAccessory(name, category, price, description) {
  const id = ++seq.accessories;
  db.accessories.push({
    id, name, category, price, description: description || '',
    createdAt: new Date().toISOString(), deletedAt: null,
  });
  return db.accessories[db.accessories.length - 1];
}

function addEmployee(fullName, position, email, salary) {
  const id = ++seq.employees;
  db.employees.push({
    id, fullName, position, email, salary,
    hiredAt: new Date().toISOString(), deletedAt: null,
  });
  return db.employees[db.employees.length - 1];
}

function addReview(customerId, phoneId, rating, comment) {
  const id = ++seq.reviews;
  db.reviews.push({
    id, customerId, phoneId, rating, comment,
    date: new Date().toISOString(), deletedAt: null,
  });
  return db.reviews[db.reviews.length - 1];
}

function addUser(username, password, fullName, email, role, readerId) {
  const id = ++seq.users;
  db.users.push({
    id,
    username,
    passwordHash: hash(password),
    fullName,
    email,
    role,
    readerId,
    createdAt: new Date().toISOString(),
  });
  return db.users[db.users.length - 1];
}

function hash(password) {
  return crypto.createHash('sha256').update(password + 'onlyphones-salt').digest('hex');
}

function cors(res) {
  res.setHeader('Access-Control-Allow-Origin', ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Max-Age', '86400');
}

function send(res, status, payload) {
  cors(res);
  if (payload === undefined || status === 204) { res.writeHead(204); res.end(); return; }
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload, null, 2));
}

function fail(res, status, message) { send(res, status, { message }); }

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

function paginate(rows, page, size) {
  const total = rows.length;
  const totalPages = Math.max(1, Math.ceil(total / size));
  return { items: rows.slice((page - 1) * size, page * size), page, size, total, totalPages };
}

const ROLE_LEVEL = { customer: 1, manager: 2, admin: 3 };

function currentUser(req) {
  const header = req.headers['authorization'] || '';
  if (!header.startsWith('Bearer ')) return null;
  const token = header.slice(7);
  const session = db.sessions[token];
  if (!session || session.type !== 'access' || session.expiresAt < Date.now()) return null;
  return db.users.find(u => u.id === session.userId) || null;
}

function requireRole(res, user, minRole) {
  if (!user) {
    fail(res, 401, 'Требуется авторизация');
    return false;
  }
  if (ROLE_LEVEL[user.role] < ROLE_LEVEL[minRole]) {
    fail(res, 403, `Операция доступна начиная с роли «${minRole}»`);
    return false;
  }
  return true;
}

function expandUser(u) {
  return { id: u.id, username: u.username, fullName: u.fullName, email: u.email, role: u.role, readerId: u.readerId };
}

async function handle(req, res, url) {
  const q = Object.fromEntries(url.searchParams.entries());
  const path = url.pathname.replace(/\/+$/, '') || '/';
  const method = req.method.toUpperCase();
  const user = currentUser(req);

  if (path === '/api/__health' && method === 'GET') return send(res, 200, { status: 'ok' });
  if (path === '/api/__reset' && method === 'POST') { seed(); return send(res, 200, { message: 'Данные восстановлены' }); }
  if (q.__fail) return fail(res, Number(q.__fail), 'Ошибка вызвана намеренно');
  if (q.__delay) await new Promise(r => setTimeout(r, Number(q.__delay)));

  // ─── AUTH ───
  if (path === '/api/auth/register' && method === 'POST') {
    const body = await readBody(req);
    const errors = {};
    const username = String(body.username || '').trim();
    const password = String(body.password || '');
    const fullName = String(body.fullName || '').trim();
    const email = String(body.email || '').trim();

    if (username.length < 3) errors.username = 'Логин не короче 3 символов';
    else if (db.users.find(u => u.username === username)) errors.username = 'Такой логин уже занят';

    if (password.length < 8) errors.password = 'Пароль не короче 8 символов';
    else if (!/\d/.test(password)) errors.password = 'Пароль должен содержать цифру';
    else if (!/[!@#$%^&*()_+\-=]/.test(password)) errors.password = 'Пароль должен содержать спецсимвол';

    if (!fullName) errors.fullName = 'Укажите ФИО';
    if (!email) errors.email = 'Укажите email';
    else if (!/^[\w.+-]+@[\w-]+\.[\w.-]+$/.test(email)) errors.email = 'Некорректный адрес почты';

    if (Object.keys(errors).length) {
      return send(res, 422, { message: 'Ошибка валидации', errors });
    }

    const newUser = addUser(username, password, fullName, email, 'customer', null);
    return send(res, 201, expandUser(newUser));
  }

  if (path === '/api/auth/login' && method === 'POST') {
    const body = await readBody(req);
    const username = String(body.username || '').trim();
    const password = String(body.password || '');

    const user = db.users.find(u => u.username === username);
    if (!user || user.passwordHash !== hash(password)) {
      return fail(res, 401, 'Неверный логин или пароль');
    }

    const now = Date.now();
    const accessToken = 'acc_' + crypto.randomBytes(16).toString('hex');
    const refreshToken = 'ref_' + crypto.randomBytes(16).toString('hex');

    db.sessions[accessToken] = { userId: user.id, expiresAt: now + ACCESS_TTL * 1000, type: 'access' };
    db.sessions[refreshToken] = { userId: user.id, expiresAt: now + 7 * 24 * 3600 * 1000, type: 'refresh' };

    return send(res, 200, {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TTL,
      user: expandUser(user),
    });
  }

  if (path === '/api/auth/refresh' && method === 'POST') {
    const body = await readBody(req);
    const token = body.refreshToken;
    const session = db.sessions[token];
    if (!session || session.type !== 'refresh' || session.expiresAt < Date.now()) {
      return fail(res, 401, 'Токен обновления недействителен');
    }
    const user = db.users.find(u => u.id === session.userId);
    if (!user) return fail(res, 401, 'Пользователь не найден');

    delete db.sessions[token];

    const now = Date.now();
    const accessToken = 'acc_' + crypto.randomBytes(16).toString('hex');
    const refreshToken = 'ref_' + crypto.randomBytes(16).toString('hex');

    db.sessions[accessToken] = { userId: user.id, expiresAt: now + ACCESS_TTL * 1000, type: 'access' };
    db.sessions[refreshToken] = { userId: user.id, expiresAt: now + 7 * 24 * 3600 * 1000, type: 'refresh' };

    return send(res, 200, {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TTL,
      user: expandUser(user),
    });
  }

  if (path === '/api/auth/me' && method === 'GET') {
    if (!user) return fail(res, 401, 'Требуется авторизация');
    return send(res, 200, expandUser(user));
  }

  if (path === '/api/auth/logout' && method === 'POST') {
    const body = await readBody(req);
    if (body.refreshToken) delete db.sessions[body.refreshToken];
    return send(res, 204);
  }

  // ─── GENERIC CRUD ───
  const entityMap = {
    'phones': { collection: 'phones', searchFields: ['model'] },
    'brands': { collection: 'brands', searchFields: ['name', 'country'] },
    'customers': { collection: 'customers', searchFields: ['fullName', 'email', 'phone'] },
    'loyalty-cards': { collection: 'loyaltyCards', searchFields: ['cardNumber'] },
    'orders': { collection: 'orders', searchFields: [] },
    'accessories': { collection: 'accessories', searchFields: ['name', 'category'] },
    'employees': { collection: 'employees', searchFields: ['fullName', 'position', 'email'] },
    'reviews': { collection: 'reviews', searchFields: ['comment'] },
  };

  for (const [entity, { collection, searchFields }] of Object.entries(entityMap)) {
    const m = path.match(new RegExp(`^\/api\/${entity}(?:\/(\\d+))?(?:\/(restore))?$`));
    if (m) {
      const id = m[1] ? Number(m[1]) : null;
      const action = m[2] || null;
      const data = db[collection];

      if (id === null && method === 'GET') {
        if (!user) return fail(res, 401, 'Требуется авторизация');

        let rows = data.filter(item => q.includeDeleted === 'true' || item.deletedAt === null);

        if (entity === 'orders' && user.role === 'customer' && user.readerId) {
          rows = rows.filter(o => o.customerId === user.readerId);
        }

        if (q.search) {
          const needle = q.search.toLowerCase();
          rows = rows.filter(item => searchFields.some(f => String(item[f]).toLowerCase().includes(needle)));
        }
        if (entity === 'phones') {
          if (q.brandId) rows = rows.filter(p => p.brandId === Number(q.brandId));
          if (q.priceFrom) rows = rows.filter(p => p.price >= Number(q.priceFrom));
          if (q.priceTo) rows = rows.filter(p => p.price <= Number(q.priceTo));
          if (q.storage) rows = rows.filter(p => p.storage === Number(q.storage));
        }
        if (entity === 'reviews') {
          if (q.phoneId) rows = rows.filter(r => r.phoneId === Number(q.phoneId));
          if (q.customerId) rows = rows.filter(r => r.customerId === Number(q.customerId));
        }
        if (entity === 'accessories') {
          if (q.category) rows = rows.filter(a => a.category === q.category);
        }
        if (entity === 'employees') {
          if (q.position) rows = rows.filter(e => e.position === q.position);
        }

        const sortField = q.sort?.split(',')[0] || (entity === 'phones' ? 'model' : 'name');
        const sortAsc = q.sort?.split(',')[1] === 'asc';
        rows.sort((a, b) => {
          const val = a[sortField] ?? '', val2 = b[sortField] ?? '';
          if (typeof val === 'number') return sortAsc ? val - val2 : val2 - val;
          return sortAsc ? String(val).localeCompare(String(val2)) : String(val2).localeCompare(String(val));
        });
        const page = Number(q.page) || 1, size = Math.min(100, Number(q.size) || 10);
        return send(res, 200, paginate(rows, page, size));
      }

      if (id !== null && method === 'GET') {
        if (!user) return fail(res, 401, 'Требуется авторизация');
        const item = data.find(item => item.id === id && (q.includeDeleted === 'true' || item.deletedAt === null));
        if (!item) return fail(res, 404, 'Запись не найдена');
        return send(res, 200, item);
      }

      if (id === null && method === 'POST') {
        if (!requireRole(res, user, 'manager')) return;

        const body = await readBody(req);

        if (entity === 'phones') {
          const existing = data.find(p => p.model.toLowerCase() === body.model.toLowerCase() && p.deletedAt === null);
          if (existing) {
            return send(res, 422, {
              message: 'Ошибка валидации',
              errors: { model: 'Телефон с такой моделью уже существует' }
            });
          }
        }

        if (entity === 'employees' && !body.hiredAt) {
          body.hiredAt = new Date().toISOString();
        }
        if (entity === 'reviews' && !body.date) {
          body.date = new Date().toISOString();
        }

        const newItem = { ...body, id: ++seq[collection], createdAt: new Date().toISOString(), deletedAt: null };
        data.push(newItem);
        return send(res, 201, newItem);
      }

      if (id !== null && method === 'PUT') {
        if (!requireRole(res, user, 'manager')) return;

        const body = await readBody(req);
        const index = data.findIndex(item => item.id === id);
        if (index === -1) return fail(res, 404, 'Запись не найдена');
        data[index] = { ...data[index], ...body };
        return send(res, 200, data[index]);
      }

      if (id !== null && method === 'DELETE') {
        const hard = q.hard === 'true';
        if (hard) {
          if (!requireRole(res, user, 'admin')) return;
        } else {
          if (!requireRole(res, user, 'manager')) return;
        }

        const index = data.findIndex(item => item.id === id);
        if (index === -1) return fail(res, 404, 'Запись не найдена');

        if (entity === 'brands') {
          const phones = db.phones.filter(p => p.brandId === id && p.deletedAt === null);
          if (phones.length > 0) {
            return send(res, 409, {
              message: `Невозможно удалить бренд: есть ${phones.length} связанных телефон(ов)`
            });
          }
        }

        if (hard) { data.splice(index, 1); }
        else { data[index].deletedAt = new Date().toISOString(); }
        return send(res, 204);
      }

      if (id !== null && action === 'restore' && method === 'POST') {
        if (!requireRole(res, user, 'admin')) return;

        const index = data.findIndex(item => item.id === id);
        if (index === -1) return fail(res, 404, 'Запись не найдена');
        data[index].deletedAt = null;
        return send(res, 200, data[index]);
      }
    }

    const bulkMatch = path.match(new RegExp(`^\/api\/${entity}\/bulk-delete$`));
    if (bulkMatch && method === 'POST') {
      if (!requireRole(res, user, 'manager')) return;

      const body = await readBody(req);
      let deleted = 0;
      for (const id of (body.ids || [])) {
        const index = data.findIndex(item => item.id === id && item.deletedAt === null);
        if (index !== -1) { data[index].deletedAt = new Date().toISOString(); deleted++; }
      }
      return send(res, 200, { deleted });
    }
  }

  // ─── USERS ───
  if (path === '/api/users' && method === 'GET') {
    if (!requireRole(res, user, 'admin')) return;
    const rows = db.users.map(expandUser);
    return send(res, 200, { items: rows, page: 1, size: rows.length, total: rows.length });
  }

  return fail(res, 404, `Адрес ${method} ${path} не обслуживается`);
}

// ─────────────────────────── ЗАПУСК ───────────────────────────
seed();

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  if (req.method === 'OPTIONS') { cors(res); res.writeHead(204); return res.end(); }
  try { await handle(req, res, url); }
  catch (err) { console.error(err); if (!res.headersSent) fail(res, 500, 'Ошибка: ' + err.message); }
});

server.listen(PORT, () => {
  console.log('');
  console.log('  🚀 OnlyPhones API (с аутентификацией и ролями)');
  console.log(`  Адрес: http://localhost:${PORT}/api`);
  console.log(`  Разрешённый источник: ${ORIGIN}`);
  console.log(`  Срок жизни токена: ${ACCESS_TTL} с`);
  console.log('');
  console.log('  Учётные записи:');
  console.log('    admin    / admin123    (администратор)');
  console.log('    manager  / manager123  (менеджер)');
  console.log('    customer / customer123 (покупатель)');
  console.log('');
  console.log('  Сброс: POST /api/__reset');
  console.log('  Задержка: ?__delay=1500');
  console.log('  Ошибка: ?__fail=500');
  console.log('  Короткий токен: --ttl 60');
  console.log('');
});