USE [Homework]
GO

/****** Object:  Table [dbo].[Account]    Script Date: 2017. 09. 23. 22:25:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account](
	[Deposit] [numeric](18, 0) NOT NULL,
	[StockValue] [numeric](18, 0) NOT NULL,
	[Sum]  AS ([Deposit]+[StockValue])
) ON [PRIMARY]

GO


/****** Object:  Table [dbo].[Article]    Script Date: 2017. 09. 23. 22:25:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Article](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Price] [numeric](18, 0) NOT NULL,
	[Stock] [int] NOT NULL,
 CONSTRAINT [PK_Article] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


USE [Homework]
GO

/****** Object:  StoredProcedure [dbo].[Buy]    Script Date: 2017. 09. 23. 22:27:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit,
	@IsolationLevel nvarchar(20)
AS

declare @Total numeric(18,0)
declare @Deposit numeric(18,0)

BEGIN

	EXEC (N'SET TRANSACTION ISOLATION LEVEL ' + @IsolationLevel + ';');

	BEGIN TRANSACTION	
		
		SELECT @Total = Price * @Quantity
		FROM Article
		WHERE [Name] = @Name

		SELECT @Deposit = Deposit
		FROM Account

		IF @Total > @Deposit 
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

		UPDATE Article
		SET Stock = Stock + @Quantity
		WHERE [Name] = @Name

	WAITFOR DELAY '00:00:01'
	
	IF @Rollback = 1 
	BEGIN
		ROLLBACK TRANSACTION
		RETURN
	END
	ELSE COMMIT TRANSACTION

	IF @Rollback = 0
	BEGIN
		UPDATE Account
		SET Deposit = Deposit - @Total, StockValue = StockValue + @Total
	END
END

GO


USE [Homework]
GO

/****** Object:  StoredProcedure [dbo].[Sell]    Script Date: 2017. 09. 23. 22:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit,
    @IsolationLevel nvarchar(20)
AS

declare @Stock numeric(18,0)
declare @Total numeric(18,0)

BEGIN

	EXEC (N'SET TRANSACTION ISOLATION LEVEL ' + @IsolationLevel + ';');

	BEGIN TRANSACTION	
		
		SELECT @Total = Price * @Quantity, @Stock = Stock
		FROM Article
		WHERE [Name] = @Name

		IF @Quantity > @Stock
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

		UPDATE Article
		SET Stock = Stock - @Quantity
		WHERE [Name] = @Name

		WAITFOR DELAY '00:00:01'

		IF @Rollback = 1
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

	ELSE COMMIT

	IF @Rollback = 0
	BEGIN
		UPDATE Account
		SET Deposit = Deposit + @Total, StockValue = StockValue - @Total
	END
END

GO


