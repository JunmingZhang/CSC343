DROP SCHEMA IF EXISTS fruits CASCADE;
CREATE SCHEMA fruits;
SET SEARCH_PATH to fruits;

-- a tables store to keep track of a store which sell fresh juice
-- description of not null: a store should have a city, phone_number and manager,
-- thus we think they should not be null
CREATE TABLE stores(
    store_id INT primary key, -- id of the store
    city VARCHAR(100) NOT NULL, -- the city the store resides
    phone_number INT NOT NULL, -- the phone number of the store
    manager VARCHAR(100) NOT NULL, -- the name of the manager of this store
    constraint oneCityOnly -- each store is in only one city, thus check for uniqueness of city
        UNIQUE(city)
);

-- info about a loyality_card, owned by customers who go to one store a lot
-- description of not null: card_home_store and number_of_tran_in_card are not null
-- since for each loyality_card, the store which they go most often to get the card
-- and how many transactions (how often) this card is used must be recorded
-- to get the card
CREATE TABLE loyality_cards(
    loyality_card_id INT primary key, -- id of the loyality_card
    card_home_store INT NOT NULL, -- the store this customer go most frequently
    number_of_tran_in_card INT NOT NULL, -- the number of transactions made
    constraint storeOfCard -- reference the home store to the info of the store
        foreign key (card_home_store) REFERENCES stores
);

-- the beverage a store sells
-- description of not null: name_of_beverage_sold, beverage_regular_calories,
-- beverage_large_calories, beverage_regular_stock, beverage_large_stock are
-- not null, since these are basic data of a beverage type and used to
-- tell the name of a beverage and distinguish regular and large beverage
CREATE TABLE beverages(
    beverage_id INT primary key, -- id of the beverage
    name_of_beverage_sold VARCHAR(100) NOT NULL, -- the name of this beverage
    beverage_regular_calories INT NOT NULL, -- the number of calories for regular size
    beverage_large_calories INT NOT NULL, -- the number of calories for large size
    constraint twoHundredMore -- the calories of the same type large size beverage is 200 more than regular one
        check (beverage_large_calories = beverage_regular_calories + 200),
    constraint oneName -- each beverage involves one name
        UNIQUE(name_of_beverage_sold)
);

-- the inventory of fruits
-- description of not null: beverage_id and amount should not be null
-- since if there is a store, some beverages should be stocked in some amount
CREATE TABLE Inventory(
    store_id INT, -- id of the store
    beverage_id INT NOT NULL, -- the id of beverage
    amount INT NOT NULL, -- the amount of fruits left
    constraint oneInventoryOneStore -- one store has one store_id in this table
        foreign key (store_id) REFERENCES stores,
    constraint oneStockOnebeverage -- one beverage has one number
        foreign key (beverage_id) REFERENCES beverages
);

-- the transaction made to buy a beverage
-- the beverage_sold_id is not null since
-- every sold beverage must be known
-- description of not null: beverage_id should not be null because there
-- is always some beverage sold per transaction
CREATE TABLE transactionInfo(
    transaction_id INT primary key, -- id of the transaction
    tran_date DATE, -- the date of transaction
    tran_price INT, -- the amount of transaction involved in the transaction
    loyality_card_id INT, -- the id used to track the loyality card
    beverage_id INT NOT NULL, -- the id of the beverage sold in the transaction
    constraint cardUsed -- the loyality card used in transaction if applicable, reference it to the info of a loyality_card
        foreign key (loyality_card_id) REFERENCES loyality_cards,
    constraint beverageInTransaction -- reference the beverage sold in this transaction to the info of a beverage
        foreign key (beverage_id) REFERENCES beverages
);

-- a relation table map a transaction to a store
-- description of not null: the foreign key reference
-- store_id is not null, because one transaction must happen
-- in a store
CREATE TABLE transactionsOfStore(
    transaction_id INT, -- the id of a transaction
    store_id INT NOT NULL, -- the id of the store for this transaction
    constraint validTransaction -- reference a valid transaction to the transactionInfo table to find info about the transaction
        foreign key (transaction_id) REFERENCES transactionInfo,
    constraint validStore -- reference the store of the transaction to the stores table to find info about the store of this transaction
        foreign key (store_id) REFERENCES stores
);

-- Insert data into table
insert into stores(store_id, city, phone_number, manager)
values
(1, 'Toronto', 1111, 'Peter'),
(2, 'Vancouver', 2222, 'Peter'),
(3, 'Ottawa', 3333, 'Daniel'),
(4, 'Shanghai', 6666, 'James'),
(5, 'Montreal', 7777, 'Daniel'),
(6, 'Beijing', 4444, 'James');

insert into beverages(beverage_id, name_of_beverage_sold, beverage_regular_calories, beverage_large_calories)
values
(111, 'Apple', 200, 400),
(222, 'Banada', 300, 500),
(333, 'Cherry', 150, 350),
(444, 'Orange', 100, 300),
(555, 'Watermelon', 450, 650),
(666, 'Peach', 310, 510),
(777, 'Blueberry', 100, 300),
(888, 'Mango', 200, 400);


insert into loyality_cards(loyality_card_id, card_home_store, number_of_tran_in_card)
values
(001, 1, 10),
(002, 2, 20),
(003, 5, 10),
(004, 1, 15),
(005, 6, 11),
(006, 1, 2),
(007, 1, 13),
(008, 5, 40),
(009, 1, 25),
(010, 4, 34),
(011, 1, 89),
(012, 3, 67),
(013, 6, 56),
(014, 4, 91),
(015, 3, 34);


insert into transactionInfo(transaction_id, tran_date, tran_price, loyality_card_id, beverage_id)
values
(1, '01/01/2018', 10, NULL, 111),
(2, '02/01/2018', 20, 001, 222),
(3, '03/01/2018', 30, NULL, 888),
(4, '04/01/2018', 40, 004, 333),
(5, '05/01/2018', 50, NULL, 111),
(6, '06/01/2018', 60, 005, 555),
(7, '07/01/2018', 70, NULL, 111),
(8, '08/01/2018', 80, 014, 777),
(9, '09/01/2018', 90, 010, 444),
(10, '10/01/2018', 10, 011, 111),
(11, '11/01/2018', 11, 008, 222),
(12, '12/01/2018', 12, 003, 888),
(13, '01/13/2018', 13, 001, 111),
(14, '01/14/2018', 14, NULL, 444),
(15, '01/15/2018', 15, 005, 777),
(16, '01/16/2018', 16, 007, 666),
(17, '01/17/2018', 17, 010, 111);

insert into transactionsOfStore(transaction_id, store_id)
values
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 2),
(6, 2),
(7, 3),
(8, 4),
(9, 4),
(10, 5),
(11, 5),
(12, 6),
(13, 6),
(14, 3);


insert into Inventory(store_id, beverage_id, amount)
values
(1, 111, 11),
(1, 222, 12),
(1, 333, 13),
(1, 444, 14),
(1, 555, 15),
(1, 666, 16),
(1, 777, 17),
(1, 888, 18),
(2, 111, 21),
(2, 222, 22),
(2, 333, 23),
(2, 444, 24),
(2, 555, 25),
(2, 666, 26),
(2, 777, 27),
(2, 888, 28),
(3, 111, 31),
(3, 222, 32),
(3, 333, 33),
(3, 444, 34),
(3, 555, 35),
(3, 666, 36),
(3, 777, 37),
(3, 888, 38),
(4, 111, 41),
(4, 222, 42),
(4, 333, 43),
(4, 444, 44),
(4, 555, 45),
(4, 666, 46),
(4, 777, 47),
(4, 888, 48),
(5, 111, 51),
(5, 222, 52),
(5, 333, 53),
(5, 444, 54),
(5, 555, 55),
(5, 666, 56),
(5, 777, 57),
(5, 888, 58),
(6, 111, 61),
(6, 222, 62),
(6, 333, 63),
(6, 444, 64),
(6, 555, 65),
(6, 666, 66),
(6, 777, 67),
(6, 888, 68);


