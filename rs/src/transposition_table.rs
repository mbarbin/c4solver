const SIZE: usize = 8_388_593;

pub struct Entry {
    pub key: usize,
    pub data: usize,
}

impl Entry {
    const ZERO: Self = Entry { key: 0, data: 0 };
}

pub struct StackStore {
    store: [Entry; SIZE],
}

impl StackStore {
    pub fn index(key: usize) -> usize {
        key % SIZE
    }

    pub fn create() -> Self {
        Self {
            store: [Entry::ZERO; SIZE],
        }
    }

    #[allow(dead_code)]
    pub fn reset(&mut self) {
        for i in 0..SIZE {
            self.store[i] = Entry::ZERO;
        }
    }

    pub fn put(&mut self, key: usize, data: usize) {
        self.store[Self::index(key)] = Entry { key, data };
    }

    pub fn get(&self, key: usize) -> usize {
        let entry = &self.store[Self::index(key)];
        if entry.key == key {
            entry.data
        } else {
            0
        }
    }
}

pub struct Store {
    store: Vec<Entry>,
}

impl Store {
    pub fn index(key: usize) -> usize {
        key % SIZE
    }

    pub fn create() -> Self {
        let mut vec = Vec::new();
        for _ in 0..SIZE {
            vec.push(Entry::ZERO);
        }
        Self { store: vec }
    }

    pub fn reset(&mut self) {
        for i in 0..SIZE {
            self.store[i] = Entry::ZERO;
        }
    }

    pub fn put(&mut self, key: usize, data: usize) {
        self.store[Self::index(key)] = Entry { key, data };
    }

    pub fn get(&self, key: usize) -> usize {
        let entry = &self.store[Self::index(key)];
        if entry.key == key {
            entry.data
        } else {
            0
        }
    }
}
