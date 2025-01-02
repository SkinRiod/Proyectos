use [dollarcity]
go

select * from dbo.Clientes
select * from dbo.DetalleVentas
select * from dbo.Empleados
select * from dbo.Productos
select * from dbo.Ventas
go

select CONCAT(clienteID,' ',Nombre,' ',Correo) as 'wasa'
from dbo.Clientes


/*Subconsulta correlacional*/
/*Cuántas unidades fueron vendidas de un producto en específico*/
select
	DP.Nombre,
	sum(DD.Cantidad) as 'Total Vendido (Unidades)'
from dbo.DetalleVentas DD
inner join dbo.Productos DP
on DD.ProductoID = DP.ProductoID
where DP.ProductoID = (
					select
						ProductoID
					from dbo.Productos
					where Nombre = 'tablet'
					)
group by DP.Nombre
go

/*Cuántas unidades fueron vendidas*/
select
	DP.Nombre,
	sum(DD.Cantidad) as 'Total Vendido (Unidades)'
from dbo.DetalleVentas DD
inner join dbo.Productos DP
on DD.ProductoID = DP.ProductoID
where DD.ProductoID = DP.ProductoID
group by DP.Nombre
go

---Creando una vista...
create view vista_unidadesvendidasxproducto as
	select
		DP.Nombre,
		sum(DD.Cantidad) as 'Total Vendido (Unidades)'
	from dbo.DetalleVentas DD
	inner join dbo.Productos DP
	on DD.ProductoID = DP.ProductoID
	where DD.ProductoID = DP.ProductoID
	group by DP.Nombre
go

---Alterando una vista...
alter view vista_unidadesvendidasxproducto as
	select
		DP.ProductoID,
		DP.Nombre,
		sum(DD.Cantidad) as 'Total Vendido (Unidades)'
	from dbo.DetalleVentas DD
	inner join dbo.Productos DP
	on DD.ProductoID = DP.ProductoID
	where DD.ProductoID = DP.ProductoID
	group by DP.Nombre, DP.ProductoID
go
/*Cuanto ha vendido en soles cada empleado*/
select
	DE.EmpleadoID,
	DE.Nombre,
	DE.Puesto,
	sum(DV.TotalVenta) 'VentalMensual'
from dbo.Empleados DE
inner join dbo.Ventas DV
on DE.EmpleadoID = DV.EmpleadoID
where month(DV.FechaVenta) = 3
group by de.EmpleadoID, DE.Nombre, DE.Puesto
order by VentalMensual desc
go

/*cuanto gasto cada cliente y Generar el reporte de ventas totales por cliente para enviar a su correo*/
select
	DC.Nombre NomCliente,
	DC.Correo,
	sum(DDV.Cantidad*DDV.PrecioUnitario) TotalGastado
from dbo.Ventas DV
inner join dbo.DetalleVentas DDV
on DV.VentaID = DDV.VentaID
inner join dbo.Clientes DC
on DV.ClienteID = DC.ClienteID
inner join dbo.Productos DP
on DDV.ProductoID = DP.ProductoID
group by DC.Nombre, DC.Correo
go

/*Que cosas ha comprado cada cliente*/
---Por ejemplo: Que compro Juan Pérez
select
	DC.Nombre NombreCliente,
	DP.Nombre NombreProducto,
	sum(DD.Cantidad) as 'Total Vendido (Unidades)'
from dbo.DetalleVentas DD
inner join dbo.Productos DP
on DD.ProductoID = DP.ProductoID
inner join dbo.Ventas DV
on DD.VentaID = DV.VentaID
inner join dbo.Clientes DC
on DV.ClienteID = DC.ClienteID
where DD.ProductoID = DP.ProductoID
and DD.VentaID in
	(select
		VentaID
	from dbo.Ventas
	where ClienteID = 13
	)
group by DP.Nombre, DC.Nombre
go

---Implementando una función...
create function itemvendidoxcliente (@idcliente int)
returns table
as return
	select
		DC.Nombre NombreCliente,
		DP.Nombre NombreProducto,
		sum(DD.Cantidad) as 'Total Vendido (Unidades)'
	from dbo.DetalleVentas DD
	inner join dbo.Productos DP
	on DD.ProductoID = DP.ProductoID
	inner join dbo.Ventas DV
	on DD.VentaID = DV.VentaID
	inner join dbo.Clientes DC
	on DV.ClienteID = DC.ClienteID
	where DD.ProductoID = DP.ProductoID
	and DD.VentaID in
		(select
			VentaID
		from dbo.Ventas
		where ClienteID = @idcliente
		)
	group by DP.Nombre, DC.Nombre
go

select *
from itemvendidoxcliente(1)
go

/*Un articulo vendido a cada cliente*/
select *
from vista_unidadesvendidasxproducto
go

select
	DC.Nombre NombreCliente,
	DP.Nombre NombreProducto,
	sum(DD.Cantidad) CantidadComprada
from dbo.DetalleVentas DD
inner join dbo.Ventas DV
on DD.VentaID = DV.VentaID
inner join dbo.Clientes DC
on DV.ClienteID = DC.ClienteID
inner join dbo.Productos DP
on DD.ProductoID = DP.ProductoID
where DD.ProductoID =
	(select
		ProductoID
	from dbo.Productos
	where Nombre = 'Auriculares')
group by DP.Nombre, DC.Nombre
go


---Máximo comprado por producto y cliente
select
    DC.Nombre NombreCliente,
    DP.Nombre NombreProducto,
    sum(DD.Cantidad) CantidadComprada
from dbo.DetalleVentas DD
inner join dbo.Ventas DV
on DD.VentaID = DV.VentaID
inner join dbo.Clientes DC
on DV.ClienteID = DC.ClienteID
inner join dbo.Productos DP 
on DD.ProductoID = DP.ProductoID
where DD.ProductoID = (
    select ProductoID
    from dbo.Productos
    where Nombre = 'mONITOR'
)
group by DC.Nombre, DP.Nombre
having sum(DD.Cantidad) = (
    select max(CantidadComprada)
    from (
        select sum(DD.Cantidad) CantidadComprada
        from dbo.DetalleVentas DD
        inner join dbo.Ventas DV
		on DD.VentaID = DV.VentaID
        inner join dbo.Clientes DC
		on DV.ClienteID = DC.ClienteID
        inner join dbo.Productos DP
		on DD.ProductoID = DP.ProductoID
        where DD.ProductoID = (
            select ProductoID
            from dbo.Productos
            where Nombre = 'mONITOR'
        )
        group by DC.Nombre, DP.Nombre
    ) as Subconsulta
)
go
