-- Cantidad de usuarios donde su apellido comience con la letra ‘M’.
SELECT 
    COUNT(*) AS Cantidad_Usuarios -- Uso la funcion COUNT para contar el numero de usuarios que cumplan con la condicion del where
FROM Customer
WHERE Apellido LIKE 'M%'; -- Utilizo el operador LIKE para filtrar por los apellidos que comiencen con la letra M 

--Listado de los usuarios que cumplan años en el día de la fecha (hoy).
SELECT * 
FROM Customer
WHERE MONTH(Fecha_Nacimiento) = MONTH(GETDATE()) AND DAY(Fecha_Nacimiento) = DAY(GETDATE()); -- Extraigo el mes con la funcion MONTH y el día con la funcion DAY de Fecha_Nacimiento que coincida con el dia de hoy o el que se consulte a traves de la funcion GETDATE()) 

-- 3. Por día se necesita, cantidad de ventas realizadas, cantidad de productos vendidos y monto total transaccionado para el mes de Enero del 2020.
SELECT
    DAY(O.Fecha_Compra) AS Dia -- Uso la funcion DAY para extraer el dia de Fecha_Compra
    ,COUNT(*) AS Cantidad_Ventas -- Uso la funcion COUNT para contar las Orders que cumplan con el filtro que tiene el where
    ,SUM(O.Cantidad) AS Cantidad_Productos -- Uso la funcion SUM para traer la cantidad de productos sumarizada 
    ,SUM(I.Precio * O.Cantidad) AS Total_Monto_Tans -- Uso la funcion SUM multiplicando los campos Precio de la tabla Item y Cantidad de la tabla Order, para obtener el monto total de las transacciones 
FROM Order O 
INNER JOIN Item I -- Realizo un Join con la tabla Item para traerme el precio de los productos vendidos
ON O.Item_Id = I.Item_Id
WHERE MONTH(Fecha_Compra) = 1 AND YEAR(Fecha_Compra) = 2020 -- En el filtro uso la funcion de MONTH y YEAR para extraer la fecha y año de el campo Fecha_Compra, indicando que sea 1 = Enero el mes y el año 2020 
GROUP BY 1 -- Agrupo los datos por dia 

/*Por cada mes del 2019, se solicita el top 5 de usuarios que más vendieron($) en la
categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del
vendedor, la cantidad vendida y el monto total transaccionado.*/
SELECT
    TOP 5 -- Uso el top con el 5 para traer solo los 5 primeros registros
    MONTH(O.Fecha_Compra) AS MES -- Extraigo el mes con la funcion MONTH
    ,YEAR(O.Fecha_Compra) AS ANIO -- Extraigo el año con la funcion YEAR
    ,C.Nombre
    ,C.Apellido
    ,SUM(O.Cantidad) AS Cantidad_Productos -- Uso la funcion SUM para traer la cantidad de productos sumarizada 
    ,SUM(I.Precio * O.Cantidad) AS Total_Monto_Tans -- Uso la funcion SUM multiplicando los campos Precio de la tabla Item y Cantidad de la tabla Order, para obtener el monto total de las transacciones 
FROM Customer C
INNER JOIN Order O 
ON C.Order_Id = O.Order_Id
INNER JOIN Item I
ON O.Item_Id = I.Item_Id
WHERE YEAR(Fecha_Compra) = 2019 -- Filtro por el año 2019, extrayendo el año con la funcion year
AND I.Category_Id = 5 -- Supongamos que 5 en la dim category equivale a celulares, para evitarnos un Join con category para traer la desc que tenga 'Celulares' en el where y asi simplificar la consulta
GROUP BY 1,2,3,4 -- Agrupo los datos por mes,año,nombre y apellido
Order By 1,6 DESC; -- Ordeno los datos por mes y por el monto total de las ventas, de mayor a menor para traer los mas vendidos

/*Se solicita poblar una tabla con el precio y estado de los Ítems a fin del día (se puede
resolver a través de StoredProcedure).
A. Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado
informado por la PK definida.
B. Esta información nos va a permitir realizar análisis para entender el
comportamiento de los diferentes Ítems (por ejemplo evolución de Precios,
cantidad de Ítems activos).*/

CREATE PROCEDURE Precio_Estado -- Creo un procedimiento almacenado llamado Precio_Estado, donde voy almacenar el query que insertara los datos
AS
BEGIN
    INSERT INTO Precio_Estado (
        Item_Id
        ,Precio
        ,Estado
        ,Fecha_Actualizacion
    ) -- Defino los campos que se insertaran segun lo requerido
    SELECT 
        I.Item_Id AS Item_Id -- Me traigo el item_id de la tabla item
        ,I.Precio AS Precio -- Me traigo el precio del item de la tabla item
        ,EI.Desc_Estado AS Estado -- Me traigo el estado del item, de la tabla Estado_Item 
        ,CAST(date, GETDATE()) AS Fecha_Actualizacion -- Para la fecha de actualizacion me traigo la fecha de hoy con getdate casteada a date
    FROM Item I
    INNER JOIN Estado_Item EI 
    ON I.Estado_Id = EI.Estado_Id -- Realizo el join por Estado_Id trayendonos el ultimo estado de cada item
    WHERE I.Fecha_Baja IS NULL; -- Traigo unicamente los item que no tenga fecha_baja 
END;

/*Desde IT nos comentan que la tabla de Categorías tiene un issue ya que cuando
generan modificaciones de una categoría se genera un nuevo registro con la misma
PK en vez de actualizar el ya existente. Teniendo en cuenta que tenemos una
columna de fecha de LastUpdated, se solicita crear una nueva tabla y poblar la
misma sin ningún tipo de duplicados garantizando la calidad y consistencia de los
datos.*/

CREATE PROCEDURE Category_Sin_Duplicados -- Creo el procedimiento almacenado que contendra la consulta que creara y insertara los datos de la nueva tabla de categoria
BEGIN
    CREATE TABLE Category_New ( -- Creo la tabla que va contener los registros unicos de categoria
        Category_Id INT PRIMARY KEY,
        Desc_Category VARCHAR(100) NOT NULL,
        Patch VARCHAR(300)  NOT NULL,
        LastUpdated DATE NOT NULL
    );
    INSERT INTO Category_New (
        Category_Id,
        Desc_Category,
        Patch,
        LastUpdated
    ) -- Realizo un insert con la consulta, usando la anterior tabla 
    SELECT 
        Category_Id,
        Desc_Category,
        Patch,
        MAX(LastUpdated) AS LastUpdated -- Uso la funcion MAX para traerme la maxima LastUpdated
    FROM Category C
    GROUP BY 1,2,3; -- Agrupo los registros por el valor de Category_Id, Desc_Category y Patch y para cada grupo seleccionare el valor maximo con la funcion MAX de LastUpdated, con esto garantizo de traerme el ultimo registro actualizado
END;

