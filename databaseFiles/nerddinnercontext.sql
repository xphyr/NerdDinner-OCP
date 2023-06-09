USE [NerdDinnerContext]
GO
/****** Object:  UserDefinedFunction [dbo].[DistanceBetween]    Script Date: 4/27/2023 4:16:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DistanceBetween] (@Lat1 as real,
                @Long1 as real, @Lat2 as real, @Long2 as real)
RETURNS real
AS
BEGIN

DECLARE @dLat1InRad as float(53);
SET @dLat1InRad = @Lat1 * (PI()/180.0);
DECLARE @dLong1InRad as float(53);
SET @dLong1InRad = @Long1 * (PI()/180.0);
DECLARE @dLat2InRad as float(53);
SET @dLat2InRad = @Lat2 * (PI()/180.0);
DECLARE @dLong2InRad as float(53);
SET @dLong2InRad = @Long2 * (PI()/180.0);

DECLARE @dLongitude as float(53);
SET @dLongitude = @dLong2InRad - @dLong1InRad;
DECLARE @dLatitude as float(53);
SET @dLatitude = @dLat2InRad - @dLat1InRad;
/* Intermediate result a. */
DECLARE @a as float(53);
SET @a = SQUARE (SIN (@dLatitude / 2.0)) + COS (@dLat1InRad)
                 * COS (@dLat2InRad)
                 * SQUARE(SIN (@dLongitude / 2.0));
/* Intermediate result c (great circle distance in Radians). */
DECLARE @c as real;
SET @c = 2.0 * ATN2 (SQRT (@a), SQRT (1.0 - @a));
DECLARE @kEarthRadius as real;
/* SET kEarthRadius = 3956.0 miles */
SET @kEarthRadius = 6376.5;        /* kms */

DECLARE @dDistance as real;
SET @dDistance = @kEarthRadius * @c;
return (@dDistance);
END
GO
/****** Object:  Table [dbo].[Dinners]    Script Date: 4/27/2023 4:16:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dinners](
	[DinnerID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[Description] [nvarchar](256) NOT NULL,
	[HostedBy] [nvarchar](20) NOT NULL,
	[ContactPhone] [nvarchar](20) NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](30) NOT NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
 CONSTRAINT [PK_Dinners] PRIMARY KEY CLUSTERED 
(
	[DinnerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[NearestDinners]    Script Date: 4/27/2023 4:16:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[NearestDinners]
	(
	@lat real,
	@long real
	)
RETURNS  TABLE
AS
	RETURN
	SELECT     Dinners.DinnerID
	FROM         Dinners 
	WHERE dbo.DistanceBetween(@lat, @long, Latitude, Longitude) <100
GO
/****** Object:  Table [dbo].[RSVP]    Script Date: 4/27/2023 4:16:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RSVP](
	[RsvpID] [int] IDENTITY(1,1) NOT NULL,
	[DinnerID] [int] NOT NULL,
	[AttendeeName] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_RSVP] PRIMARY KEY CLUSTERED 
(
	[RsvpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RSVP]  WITH CHECK ADD  CONSTRAINT [FK_RSVP_Dinners] FOREIGN KEY([DinnerID])
REFERENCES [dbo].[Dinners] ([DinnerID])
GO
ALTER TABLE [dbo].[RSVP] CHECK CONSTRAINT [FK_RSVP_Dinners]
GO
