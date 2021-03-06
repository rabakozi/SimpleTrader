USE [Homework]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 9/27/2017 5:30:41 PM ******/
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
/****** Object:  Table [dbo].[Article]    Script Date: 9/27/2017 5:30:41 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Buy]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

declare @Total numeric(18,0)
declare @Deposit numeric(18,0)

BEGIN

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

		SELECT @Deposit = Deposit 
		FROM Account
			
		IF @Rollback = 1 --OR @Total > @Deposit 
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
/****** Object:  StoredProcedure [dbo].[Buy_ReadCommitted]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy_ReadCommitted] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	EXEC dbo.Buy @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Buy_ReadUncommitted]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy_ReadUncommitted] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	EXEC dbo.Buy @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Buy_RepeatableRead]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy_RepeatableRead] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

	EXEC dbo.Buy @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Buy_Serializable]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy_Serializable] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	EXEC dbo.Buy @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Buy_Snapshot]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Buy_Snapshot] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	EXEC dbo.Buy @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Sell]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

declare @Stock numeric(18,0)
declare @Total numeric(18,0)

BEGIN


	BEGIN TRANSACTION	
		
		SELECT @Total = Price * @Quantity --, @Stock = Stock
		FROM Article
		WHERE [Name] = @Name

		--IF @Quantity > @Stock
		--BEGIN
		--	ROLLBACK TRANSACTION
		--	RETURN
		--END

		UPDATE Article
		SET Stock = Stock - @Quantity
		WHERE [Name] = @Name AND @Quantity < Stock

		WAITFOR DELAY '00:00:01'
	
	--ELSE 
	COMMIT

	IF @Rollback = 0
	BEGIN
		UPDATE Account
		SET Deposit = Deposit + @Total, StockValue = StockValue - @Total
	END
END


GO
/****** Object:  StoredProcedure [dbo].[Sell_ReadCommitted]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell_ReadCommitted] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	EXEC dbo.Sell @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Sell_ReadUncommitted]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell_ReadUncommitted] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	EXEC dbo.Sell @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Sell_RepeatableRead]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell_RepeatableRead] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

	EXEC dbo.Sell @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Sell_Serializable]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell_Serializable] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

	EXEC dbo.Sell @Name, @Quantity, @Rollback
	
END


GO
/****** Object:  StoredProcedure [dbo].[Sell_Snapshot]    Script Date: 9/27/2017 5:30:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sell_Snapshot] 
	@Name nvarchar(20),
	@Quantity int,
	@Rollback bit
AS

BEGIN

    SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	EXEC dbo.Sell @Name, @Quantity, @Rollback
	
END


GO
