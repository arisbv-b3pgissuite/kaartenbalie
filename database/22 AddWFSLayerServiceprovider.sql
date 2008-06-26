CREATE TABLE wfs_layer (
  WFSLAYERID INTEGER NOT NULL AUTO_INCREMENT,
  WFSSERVICEPROVIDERID INTEGER,
  NAME VARCHAR(50),
  TITLE VARCHAR(200) NOT NULL,
  METADATA TEXT,
  PRIMARY KEY (WFSLAYERID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE wfs_serviceprovider (
  WFSSERVICEPROVIDERID INTEGER NOT NULL AUTO_INCREMENT,
  NAME VARCHAR(60) NOT NULL,
  TITLE VARCHAR(50) NOT NULL,
  GIVENNAME VARCHAR(50),
  URL VARCHAR(4000),
  UPDATEDDATE DATETIME,
  WFSVERSION VARCHAR(50),
  ABBR VARCHAR(60),
  PRIMARY KEY (WFSSERVICEPROVIDERID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE wfs_layer ADD CONSTRAINT FK_wfs_layer_1 FOREIGN KEY FK_wfs_layer_1 (WFSSERVICEPROVIDERID)
    REFERENCES wfs_serviceprovider (WFSSERVICEPROVIDERID)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;
   
CREATE TABLE wfs_organizationlayer (
  ORGANIZATIONID INTEGER NOT NULL,
  WFSLAYERID INTEGER NOT NULL,
  PRIMARY KEY (ORGANIZATIONID, WFSLAYERID),
  CONSTRAINT FK_wfs_organisationlayer_1 FOREIGN KEY FK_wfs_organisationlayer_1 (WFSLAYERID)
    REFERENCES wfs_layer (WFSLAYERID)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT FK_wfs_organisationlayer_2 FOREIGN KEY FK_wfs_organisationlayer_2 (ORGANIZATIONID)
    REFERENCES organization (ORGANIZATIONID)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT) ENGINE=InnoDB DEFAULT CHARSET=utf8;