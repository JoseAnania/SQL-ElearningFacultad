--Integrantes: 
-- Anania, José 109257
-- Codina, Pablo 110021
-- Ryser, Pablo 109101

/************************************/
/* 1.- CREACIÓN DE LA BASE DE DATOS */
/************************************/

CREATE DATABASE TP_DYAB
USE TP_DYAB

CREATE TABLE Profesor
(
idProfesor NUMERIC IDENTITY (1,1) NOT NULL,
nombre NVARCHAR(30),
apellido NVARCHAR(30),
dni INT NOT NULL,
telefono VARCHAR(20),
CONSTRAINT PK_Profesor PRIMARY KEY (idProfesor),
CONSTRAINT dniUnicoP UNIQUE(dni)
)

CREATE TABLE Alumno
(
legajo NUMERIC NOT NULL,
nombre NVARCHAR(30),
apellido NVARCHAR(30),
dni INT NOT NULL,
telefono VARCHAR(20),
CONSTRAINT PK_Alumno PRIMARY KEY (legajo),
CONSTRAINT dniUnicoA UNIQUE(dni)
)

CREATE TABLE Materia
(
idMateria NUMERIC IDENTITY (1,1) NOT NULL,
nombre NVARCHAR(30),
cuatrimestre NVARCHAR(10),
anio NVARCHAR(10),
CONSTRAINT PK_Materia PRIMARY KEY (idMateria),
)

CREATE TABLE Inscripcion
(
idInscripcion NUMERIC IDENTITY (1,1) NOT NULL,
idMateria NUMERIC,
legajo NUMERIC,
fechaInscripcion SMALLDATETIME,
CONSTRAINT PK_Inscripcion PRIMARY KEY (idInscripcion),
CONSTRAINT FK_Inscripcion_Materia FOREIGN KEY (idMateria) REFERENCES Materia (idMateria),
CONSTRAINT FK_Inscripcion_Alumno FOREIGN KEY (legajo) REFERENCES Alumno (legajo),
)

CREATE TABLE TipoRecurso
(
idTipoRecurso NUMERIC IDENTITY (1,1) NOT NULL,
nombre NVARCHAR(50),
CONSTRAINT PK_TipoRecurso PRIMARY KEY (idTipoRecurso),
)

CREATE TABLE Acceso
(
idAcceso NUMERIC IDENTITY (1,1) NOT NULL,
nombre NVARCHAR(20),
CONSTRAINT PK_Acceso PRIMARY KEY (idAcceso),
)

CREATE TABLE Recurso
(
idRecurso NUMERIC IDENTITY (1,1) NOT NULL,
idMateria NUMERIC,
idProfesor NUMERIC,
idTipoRecurso NUMERIC,
idAcceso NUMERIC,
fechaSubida SMALLDATETIME,
CONSTRAINT PK_Recurso PRIMARY KEY (idRecurso),
CONSTRAINT FK_Recurso_Materia FOREIGN KEY (idMateria) REFERENCES Materia (idMateria),
CONSTRAINT FK_Recurso_Profesor FOREIGN KEY (idProfesor) REFERENCES Profesor (idProfesor),
CONSTRAINT FK_Recurso_TipoRecurso FOREIGN KEY (idTipoRecurso) REFERENCES TipoRecurso (idTipoRecurso),
CONSTRAINT FK_Recurso_Acceso FOREIGN KEY (idAcceso) REFERENCES Acceso (idAcceso),
)

CREATE TABLE Descarga
(
idDescarga NUMERIC IDENTITY (1,1) NOT NULL,
idRecurso NUMERIC,
legajo NUMERIC,
fechaDescarga SMALLDATETIME,
CONSTRAINT PK_Descarga PRIMARY KEY (idDescarga),
CONSTRAINT FK_Descarga_Recurso FOREIGN KEY (idRecurso) REFERENCES Recurso (idRecurso),
CONSTRAINT FK_Descarga_Alumno FOREIGN KEY (legajo) REFERENCES Alumno (legajo)
)

CREATE TABLE ProfesorXMateria
(
idProfesor NUMERIC,
idMateria NUMERIC,
CONSTRAINT PK_ProfesorMateria PRIMARY KEY (idProfesor, idMateria),
CONSTRAINT FK_ProfesorMateria_Profesor FOREIGN KEY (idProfesor) REFERENCES Profesor (idProfesor),
CONSTRAINT FK_PorfesorMateria_Materia FOREIGN KEY (idMateria) REFERENCES Materia (idMateria)
)

/*Procedimiento PARA MOSTRAR ERRORES*/

CREATE PROCEDURE mostrarErrores
AS
	PRINT N'La transacción se ha completado con errores'
	SELECT  
		ERROR_NUMBER() AS 'Número de error', 
		ERROR_SEVERITY() AS 'Severidad', 
		ERROR_STATE() AS 'Estado', 
		ERROR_LINE() AS 'Línea', 
		ERROR_PROCEDURE() AS 'Procedure/Trigger', 
		ERROR_MESSAGE() AS 'Mensaje'

/*FUNCION PARA VERIFICAR SI EXISTE UN DNI (de Profesor y Alumno)*/

CREATE FUNCTION existeDniP(@dni INT) 
RETURNS INT
	AS
		BEGIN 
			DECLARE @ret INT 
			SELECT @ret = dni FROM Profesor where dni = @dni
			IF (@ret IS NULL)
				SET @ret = 0
			RETURN @ret
		END

CREATE FUNCTION existeDniA(@dni INT) 
RETURNS INT
	AS
		BEGIN 
			DECLARE @ret INT 
			SELECT @ret = dni FROM Alumno where dni = @dni
			IF (@ret IS NULL)
				SET @ret = 0
			RETURN @ret
		END

/*ABMC DE ALUMNOS*/

CREATE PROCEDURE AltaAlumno 
@legajo NUMERIC,
@nombre NVARCHAR(30),
@apellido NVARCHAR(30),
@dni INT,
@telefono VARCHAR(20)
AS 
	BEGIN TRY 
		INSERT INTO Alumno VALUES (@legajo, @nombre, @apellido, @dni, @telefono)
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaAlumno 109257, 'Eddie', 'Vedder', 20213654, NULL -- Inserta
EXEC AltaAlumno 100100, 'Mick', 'Jagger', 28655784, 3515555284 -- Inserta
EXEC AltaAlumno 100100, 'Mick', 'Jagger', 20213654, 3515555284 -- Muestra Error de DNI duplicado

CREATE PROCEDURE BajaAlumno 
@legajo NUMERIC
AS 
	BEGIN TRY 
		DELETE FROM Alumno WHERE legajo=@legajo
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC BajaAlumno 100100 -- Elimina

CREATE PROCEDURE ModificaAlumno 
@legajo NUMERIC,
@nombre NVARCHAR(30),
@apellido NVARCHAR(30),
@dni INT,
@telefono VARCHAR(20)
AS 
	BEGIN TRY 
		UPDATE Alumno SET nombre=@nombre, apellido=@apellido, dni=@dni, telefono=@telefono 
		WHERE legajo=@legajo
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC ModificaAlumno 109257, 'Eddie', 'Vedder', 20213654, 4737773 -- Modifica

CREATE VIEW ConsultaAlumno
AS
	SELECT * FROM Alumno 
	
SELECT * FROM ConsultaAlumno --Al ser una tabla independiente no tiene mucho sentido la vista

/*ABMC DE MATERIAS*/

CREATE PROCEDURE AltaMateria 
@nombre NVARCHAR(30),
@cuatrimestre NVARCHAR(10),
@anio NVARCHAR(10)
AS 
	BEGIN TRY 
		INSERT INTO Materia VALUES (@nombre, @cuatrimestre, @anio)
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaMateria 'Programación II', '1°', '2°' -- Inserta
EXEC AltaMateria 'Dyab', '2°', '1°' -- Inserta

CREATE PROCEDURE BajaMateria 
@idMateria NUMERIC
AS 
	BEGIN TRY 
		DELETE FROM Materia WHERE idMateria=@idMateria
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC BajaMateria 2 -- Elimina

CREATE PROCEDURE ModificaMateria 
@idMateria NUMERIC,
@nombre NVARCHAR(30),
@cuatrimestre NVARCHAR(10),
@anio NVARCHAR(10)
AS 
	BEGIN TRY 
		UPDATE Materia SET nombre=@nombre, cuatrimestre=@cuatrimestre, anio=@anio
		WHERE idMateria=@idMateria
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC ModificaMateria 1, 'Programación II', '2°', '2°' -- Modifica

CREATE VIEW ConsultaMateria
AS
	SELECT * FROM Materia 
	
SELECT * FROM ConsultaMateria --Al ser una tabla independiente no tiene mucho sentido la vista

/*ABMC DE PROFESORES*/

CREATE PROCEDURE AltaProfesor 
@nombre NVARCHAR(30),
@apellido NVARCHAR(30),
@dni INT,
@telefono VARCHAR(20)
AS 
	BEGIN TRY 
		INSERT INTO Profesor VALUES (@nombre, @apellido, @dni, @telefono)
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaProfesor 'Karl', 'Marx', 05468975, 4247404 -- Inserta
EXEC AltaProfesor 'Mick', 'Jagger', 28655784, 3515555284 -- Inserta
EXEC AltaProfesor 'Mick', 'Jagger', 05468975, 3515555284 -- Muestra Error de DNI duplicado

CREATE PROCEDURE BajaProfesor
@idProfesor NUMERIC
AS 
	BEGIN TRY 
		DELETE FROM Profesor WHERE idProfesor=@idProfesor
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC BajaProfesor 2 -- Elimina

CREATE PROCEDURE ModificaProfesor
@idProfesor NUMERIC,
@nombre NVARCHAR(30),
@apellido NVARCHAR(30),
@dni INT,
@telefono VARCHAR(20)
AS 
	BEGIN TRY 
		UPDATE Profesor SET nombre=@nombre, apellido=@apellido, dni=@dni, telefono=@telefono 
		WHERE idProfesor=@idProfesor
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC ModificaProfesor 1, 'Kurt', 'Cobain', 18963852, 4255842 -- Modifica

CREATE VIEW ConsultaProfesor
AS
	SELECT * FROM Profesor 
	
SELECT * FROM ConsultaProfesor --Al ser una tabla independiente no tiene mucho sentido la vista

/*ABMC DE INSCRIPCION*/

CREATE PROCEDURE AltaInscripcion 
@idMateria NUMERIC,
@legajo NUMERIC
AS 
	BEGIN TRY 
		INSERT INTO Inscripcion VALUES (@idMateria, @legajo, GETDATE())
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaInscripcion 1, 109257  -- Inserta

CREATE PROCEDURE ModificaInscripcion
@idInscripcion NUMERIC,
@idMateria NVARCHAR(30),
@legajo NVARCHAR(30),
@fechaInscripcion SMALLDATETIME
AS 
	BEGIN TRY 
		UPDATE Inscripcion SET idMateria=@idMateria, legajo=@legajo, fechaInscripcion=@fechaInscripcion 
		WHERE idInscripcion=@idInscripcion
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC ModificaInscripcion 1, 1, 109257, '22/10/2018' -- Modifica

CREATE PROCEDURE BajaInscripcion
@idInscripcion NUMERIC
AS 
	BEGIN TRY 
		DELETE FROM Inscripcion WHERE idInscripcion=@idInscripcion
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC BajaInscripcion 1 -- Elimina

CREATE VIEW ConsultaInscripcion
AS
	SELECT i.idInscripcion, i.fechaInscripcion, m.nombre AS 'Materia', a.apellido+', '+a.nombre AS 'Alumno' 
	FROM Inscripcion i
	INNER JOIN Materia m ON i.idMateria=m.idMateria
	INNER JOIN Alumno a ON i.legajo=a.legajo
	
SELECT * FROM ConsultaInscripcion --Consulta

/*ALTA Y BORRADO DE RECURSOS*/


INSERT INTO Acceso VALUES('Público')
INSERT INTO Acceso VALUES('Privado')

INSERT INTO TipoRecurso VALUES('Pdf')
INSERT INTO TipoRecurso VALUES('Video')
INSERT INTO TipoRecurso VALUES('Tarea')
INSERT INTO TipoRecurso VALUES('Cuestionario')


CREATE PROCEDURE AltaRecurso 
@idMateria NUMERIC,
@idProfesor NUMERIC,
@idTipoRecurso NUMERIC,
@idAcceso NUMERIC
AS 
	BEGIN TRY 
		INSERT INTO Recurso VALUES (@idMateria, @idProfesor, @idTipoRecurso, @idAcceso, GETDATE())
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaRecurso 2, 2, 2, 1 --Inserta

CREATE PROCEDURE BajaRecurso
@idRecurso NUMERIC
AS 
	BEGIN TRY 
		DELETE FROM Recurso WHERE idRecurso=@idRecurso
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC BajaRecurso 1 --Elimina

/*REGISTRACION DE DESCARGAS*/ 

CREATE PROCEDURE AltaDescarga 
@idRecurso NUMERIC,
@legajo NUMERIC
AS 
	BEGIN TRY 
		INSERT INTO Descarga VALUES (@idRecurso, @legajo, GETDATE())
	END TRY
		BEGIN CATCH
			EXEC mostrarErrores
		END CATCH

EXEC AltaDescarga 2, null --Inserta descarga pública
EXEC AltaDescarga 2, 100100 --Inserta descarga privada

CREATE VIEW ConsultaDescarga
AS
	SELECT tr.nombre AS 'ARCHIVO', p.nombre+' '+p.apellido AS 'SUBIDO POR', a.nombre AS 'ACCESO', d.fechaDescarga AS 'FECHA DE DESCARGA', d.legajo AS 'DESCARGADO POR'
	FROM Descarga d
	INNER JOIN Recurso r ON d.idRecurso=r.idRecurso
	INNER JOIN TipoRecurso tr ON r.idTipoRecurso=tr.idTipoRecurso
	INNER JOIN Profesor p ON r.idProfesor=p.idProfesor
	INNER JOIN Acceso a ON r.idAcceso=a.idAcceso

SELECT * FROM ConsultaDescarga

/*REPORTES*/

--Listado de alumnos por materia

CREATE VIEW AlumnosMaterias
AS
	SELECT a.legajo AS 'Legajo', a.nombre+' '+a.apellido AS 'Alumno', m.nombre AS 'Materia', i.fechaInscripcion AS 'Fecha de Inscripción'
	FROM Alumno a
	INNER JOIN Inscripcion i ON a.legajo=i.legajo
	INNER JOIN Materia m ON i.idMateria=m.idMateria
	
SELECT * FROM AlumnosMaterias 
ORDER BY 'Materia' ASC

--Listado de recursos públicos, indicando total de descargas.

CREATE VIEW RecursosPublicosDescargas
AS
	SELECT tr.nombre AS 'ARCHIVO', p.nombre+' '+p.apellido AS 'SUBIDO POR', COUNT(*) AS 'CANTIDAD DESCARGAS'
	FROM Descarga d
	INNER JOIN Recurso r ON d.idRecurso=r.idRecurso
	INNER JOIN TipoRecurso tr ON r.idTipoRecurso=tr.idTipoRecurso
	INNER JOIN Profesor p ON r.idProfesor=p.idProfesor
	WHERE d.legajo IS NULL
	GROUP BY TR.nombre, p.nombre+' '+p.apellido

SELECT * FROM RecursosPublicosDescargas

--Seleccionando un alumno, mostrar el listado de todas las descargas y
--el porcentaje de descargas de cada materia. El porcentaje se calcula
--como la cantidad de recursos descargados sobre el total de recursos
--disponibles de la materia. Debe indicarse con un color especial las
--materias para las que el alumno descargó menos del 50% del
--material.

--Listado de actividad de profesores, indicando por cada uno la
--cantidad de materiales subidos, la cantidad de descargas de sus
--materiales y el promedio de descargas por materia.
