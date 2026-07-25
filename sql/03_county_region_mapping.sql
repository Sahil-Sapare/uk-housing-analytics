-- Maps HM Land Registry county values onto ONS regions.
--
-- Land Registry uses a mix of ceremonial counties, unitary authorities, and
-- historic counties abolished in the 1990s (AVON, CLEVELAND, HEREFORD AND
-- WORCESTER, THAMESDOWN). All appear in the data and all are mapped here.
--
-- Note: 'WEST MIDLANDS' appears both as a county (the metropolitan area
-- around Birmingham) and as a region name. They are distinct things that
-- happen to share a name.

CREATE TABLE county_region_map (
    county      TEXT PRIMARY KEY,
    region_name TEXT NOT NULL REFERENCES dim_region(name)
);

INSERT INTO county_region_map (county, region_name) VALUES
    -- North East
    ('COUNTY DURHAM', 'North East'),
    ('DARLINGTON', 'North East'),
    ('DURHAM', 'North East'),
    ('HARTLEPOOL', 'North East'),
    ('MIDDLESBROUGH', 'North East'),
    ('NORTHUMBERLAND', 'North East'),
    ('REDCAR AND CLEVELAND', 'North East'),
    ('STOCKTON-ON-TEES', 'North East'),
    ('TYNE AND WEAR', 'North East'),
    ('CLEVELAND', 'North East'),

    -- North West
    ('BLACKBURN WITH DARWEN', 'North West'),
    ('BLACKPOOL', 'North West'),
    ('CHESHIRE', 'North West'),
    ('CHESHIRE EAST', 'North West'),
    ('CHESHIRE WEST AND CHESTER', 'North West'),
    ('CUMBERLAND', 'North West'),
    ('CUMBRIA', 'North West'),
    ('GREATER MANCHESTER', 'North West'),
    ('HALTON', 'North West'),
    ('LANCASHIRE', 'North West'),
    ('MERSEYSIDE', 'North West'),
    ('WARRINGTON', 'North West'),
    ('WESTMORLAND AND FURNESS', 'North West'),

    -- Yorkshire and The Humber
    ('EAST RIDING OF YORKSHIRE', 'Yorkshire and The Humber'),
    ('CITY OF KINGSTON UPON HULL', 'Yorkshire and The Humber'),
    ('HUMBERSIDE', 'Yorkshire and The Humber'),
    ('NORTH EAST LINCOLNSHIRE', 'Yorkshire and The Humber'),
    ('NORTH LINCOLNSHIRE', 'Yorkshire and The Humber'),
    ('NORTH YORKSHIRE', 'Yorkshire and The Humber'),
    ('SOUTH YORKSHIRE', 'Yorkshire and The Humber'),
    ('WEST YORKSHIRE', 'Yorkshire and The Humber'),
    ('YORK', 'Yorkshire and The Humber'),

    -- East Midlands
    ('CITY OF DERBY', 'East Midlands'),
    ('CITY OF NOTTINGHAM', 'East Midlands'),
    ('DERBYSHIRE', 'East Midlands'),
    ('LEICESTER', 'East Midlands'),
    ('LEICESTERSHIRE', 'East Midlands'),
    ('LINCOLNSHIRE', 'East Midlands'),
    ('NORTH NORTHAMPTONSHIRE', 'East Midlands'),
    ('NORTHAMPTONSHIRE', 'East Midlands'),
    ('NOTTINGHAMSHIRE', 'East Midlands'),
    ('RUTLAND', 'East Midlands'),
    ('WEST NORTHAMPTONSHIRE', 'East Midlands'),

    -- West Midlands
    ('HEREFORD AND WORCESTER', 'West Midlands'),
    ('HEREFORDSHIRE', 'West Midlands'),
    ('SHROPSHIRE', 'West Midlands'),
    ('STAFFORDSHIRE', 'West Midlands'),
    ('STOKE-ON-TRENT', 'West Midlands'),
    ('WARWICKSHIRE', 'West Midlands'),
    ('WEST MIDLANDS', 'West Midlands'),
    ('WORCESTERSHIRE', 'West Midlands'),
    ('WREKIN', 'West Midlands'),

    -- East
    ('BEDFORD', 'East'),
    ('BEDFORDSHIRE', 'East'),
    ('CAMBRIDGESHIRE', 'East'),
    ('CENTRAL BEDFORDSHIRE', 'East'),
    ('CITY OF PETERBOROUGH', 'East'),
    ('ESSEX', 'East'),
    ('HERTFORDSHIRE', 'East'),
    ('LUTON', 'East'),
    ('NORFOLK', 'East'),
    ('SOUTHEND-ON-SEA', 'East'),
    ('SUFFOLK', 'East'),
    ('THURROCK', 'East'),

    -- London
    ('GREATER LONDON', 'London'),

    -- South East
    ('BERKSHIRE', 'South East'),
    ('BRACKNELL FOREST', 'South East'),
    ('BRIGHTON AND HOVE', 'South East'),
    ('BUCKINGHAMSHIRE', 'South East'),
    ('EAST SUSSEX', 'South East'),
    ('HAMPSHIRE', 'South East'),
    ('ISLE OF WIGHT', 'South East'),
    ('KENT', 'South East'),
    ('MEDWAY', 'South East'),
    ('MILTON KEYNES', 'South East'),
    ('OXFORDSHIRE', 'South East'),
    ('PORTSMOUTH', 'South East'),
    ('READING', 'South East'),
    ('SLOUGH', 'South East'),
    ('SOUTHAMPTON', 'South East'),
    ('SURREY', 'South East'),
    ('WEST BERKSHIRE', 'South East'),
    ('WEST SUSSEX', 'South East'),
    ('WINDSOR AND MAIDENHEAD', 'South East'),
    ('WOKINGHAM', 'South East'),

    -- South West
    ('AVON', 'South West'),
    ('BATH AND NORTH EAST SOMERSET', 'South West'),
    ('BOURNEMOUTH', 'South West'),
    ('BOURNEMOUTH, CHRISTCHURCH AND POOLE', 'South West'),
    ('CITY OF BRISTOL', 'South West'),
    ('CITY OF PLYMOUTH', 'South West'),
    ('CORNWALL', 'South West'),
    ('DEVON', 'South West'),
    ('DORSET', 'South West'),
    ('GLOUCESTERSHIRE', 'South West'),
    ('ISLES OF SCILLY', 'South West'),
    ('NORTH SOMERSET', 'South West'),
    ('POOLE', 'South West'),
    ('SOMERSET', 'South West'),
    ('SOUTH GLOUCESTERSHIRE', 'South West'),
    ('SWINDON', 'South West'),
    ('THAMESDOWN', 'South West'),
    ('TORBAY', 'South West'),
    ('WILTSHIRE', 'South West'),

    -- Wales
    ('BLAENAU GWENT', 'Wales'),
    ('BRIDGEND', 'Wales'),
    ('CAERPHILLY', 'Wales'),
    ('CARDIFF', 'Wales'),
    ('CARMARTHENSHIRE', 'Wales'),
    ('CEREDIGION', 'Wales'),
    ('CLWYD', 'Wales'),
    ('CONWY', 'Wales'),
    ('DENBIGHSHIRE', 'Wales'),
    ('DYFED', 'Wales'),
    ('FLINTSHIRE', 'Wales'),
    ('GWENT', 'Wales'),
    ('GWYNEDD', 'Wales'),
    ('ISLE OF ANGLESEY', 'Wales'),
    ('MERTHYR TYDFIL', 'Wales'),
    ('MID GLAMORGAN', 'Wales'),
    ('MONMOUTHSHIRE', 'Wales'),
    ('NEATH PORT TALBOT', 'Wales'),
    ('NEWPORT', 'Wales'),
    ('PEMBROKESHIRE', 'Wales'),
    ('POWYS', 'Wales'),
    ('RHONDDA CYNON TAFF', 'Wales'),
    ('SOUTH GLAMORGAN', 'Wales'),
    ('SWANSEA', 'Wales'),
    ('THE VALE OF GLAMORGAN', 'Wales'),
    ('TORFAEN', 'Wales'),
    ('WEST GLAMORGAN', 'Wales'),
    ('WREXHAM', 'Wales');
