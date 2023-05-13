-- El codigo proporcionado tiene sintaxis de SQL server
-- Creacion de la tabla Customer
CREATE TABLE Customer (
    Customer_Id INT PRIMARY KEY,
    Nombre VARCHAR(20) NOT NULL,
    Apellido VARCHAR(20) NOT NULL,
    Sexo CHAR(1) NOT NULL,
    Direccion VARCHAR(200) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Fecha_Nacimiento DATE NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    Order_Id INT NOT NULL,
    FOREIGN KEY (Order_Id) REFERENCES Order(Order_Id)
);

-- Creacion de la tabla Order
CREATE TABLE Order (
    Order_Id INT PRIMARY KEY,
    Fecha_Compra DATETIME NOT NULL,
    Cantidad INT NOT NULL,
    Customer_Id INT NOT NULL,
    Item_Id INT NOT NULL,
    FOREIGN KEY (Customer_Id) REFERENCES Customer(Customer_Id),
    FOREIGN KEY (Item_Id) REFERENCES Item(Item_Id)
);

-- Creacion de la tabla Item
CREATE TABLE Item (
    Item_Id INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Desc_Item VARCHAR(200) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Fecha_Baja DATE NOT NULL,
    Estado_Id INT NOT NULL,
    Category_Id INT NOT NULL,
    FOREIGN KEY (Estado_Id) REFERENCES Estado_Item(Estado_Id),
    FOREIGN KEY (Category_Id) REFERENCES Category(Category_Id)
);

-- Creacion de la tabla Estado_Item
CREATE TABLE Estado_Item (
    Estado_Id INT PRIMARY KEY,
    Desc_Estado VARCHAR(20) NOT NULL
);

-- Creacion de la tabla Category
CREATE TABLE Category (
    Category_Id INT PRIMARY KEY,
    Desc_Category VARCHAR(100) NOT NULL,
    Patch VARCHAR(300)  NOT NULL
);

-- Cree una tabla adicional para guardar el estado que puede tener cada item