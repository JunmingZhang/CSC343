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

-- a relation table map a transaction to a store
-- description of not null: the foreign key reference
-- store_id is not null, because one transaction must happen
-- in a store
CREATE TABLE transactionsOfStore(
    transaction_id INT, -- the id of a transaction
    store_id INT NOT NULL, -- the id of the store for this transaction
    constraint validTransaction -- reference a valid transaction to the transactionInfo table to find info about the transaction
        foreign key transaction_id REFERENCES transactionInfo(transaction_id),
    constraint validStore -- reference the store of the transaction to the stores table to find info about the store of this transaction
        foreign key store_id REFERENCES stores(store_id)
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
        foreign key card_home_store REFERENCES stores(store_id)
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
    beverage_regular_stock INT NOT NULL, -- the number of regular beverages stocked
    beverage_large_stock INT NOT NULL, -- the number of large beverages stocked
    constraint twoHundredMore -- the calories of the same type large size beverage is 200 more than regular one
        check (beverage_large_calories = beverage_regular_calories + 200)
);

-- the transaction made to buy a beverage
-- the beverage_sold_id is not null since
-- every sold beverage must be known
CREATE TABLE transactionInfo(
    transaction_id INT primary key, -- id of the transaction
    tran_date DATE, -- the date of transaction
    tran_price INT, -- the amount of transaction involved in the transaction
    loyality_card_id INT, -- the id used to track the loyality card
    beverage_id INT NOT NULL -- the id of the beverage sold in the transaction
    constraint cardUsed -- the loyality card used in transaction if applicable, reference it to the info of a loyality_card
        foreign key loyality_card_id REFERENCES loyality_cards(loyality_card_id),
    constraint beverageInTransaction -- reference the beverage sold in this transaction to the info of a beverage
        foreign key beverage_id REFERENCES beverages(beverage_id),
    constraint oneBeverage -- each transaction involves one beverage
        UNIQUE(beverage_id)
);