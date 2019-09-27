WHENEVER SQLERROR CONTINUE; -- continue on error
DROP SEQUENCE SEQ_WAVEFORM_ID;
DROP SEQUENCE SEQ_WAVEFORM_ID2;
DROP TABLE ML_WAVEFORMS;

WHENEVER SQLERROR EXIT FAILURE; -- exit on error from now on


-- sequence for waveform id
CREATE SEQUENCE SEQ_WAVEFORM_ID2 START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE ML_WAVEFORMS
(
  WAVEFORMID        NUMBER NOT NULL PRIMARY KEY,
  ARID              NUMBER NOT NULL,
  TIMEA             FLOAT,  -- time of automatic detection, N phase or manual detection can have NULL
  TIMELEB           FLOAT,  -- onset time in LEB, N phase can have NULL  
  IPHASE            VARCHAR2(8), -- iwt label
  IPHASECL          VARCHAR2(8), -- iwt class
  IPHASECLNUM       NUMBER, -- iwt class numerical code (for confidence matrix)
  PHASE             VARCHAR2(8),  -- phase label as in LEB assoc
  PHASECL           VARCHAR2(8),  -- phase class
  PHASECLNUM        NUMBER,  -- phase class numerical code (for confidence matrix)
  SOURCE            VARCHAR2(1), -- A - automatic phase family type remained after association, H - automatic phase family changed by analyst, M - manually added by analysts (no automatice detection) 
  STA               VARCHAR2(8) NOT NULL,
  CHANNELS          VARCHAR2(20) NOT NULL,
  SAMPRATE          FLOAT,
  STARTTIME         FLOAT,
  ENDTIME           FLOAT,
  NSAMP             NUMBER,
  CALIBS             FLOAT,
  SAMPLES           BLOB --calibrated to 4byte float samples in binary
) ENABLE PRIMARY KEY USING INDEX;


CREATE INDEX IDX_ML_WAVEFORMS_TIME ON ML_WAVEFORMS(TIMELEB);
CREATE INDEX IDX_ML_WAVEFORMS_STA ON ML_WAVEFORMS(STA);

ALTER INDEX IDX_ML_WAVEFORMS_TIME REBUILD;
ALTER INDEX IDX_ML_WAVEFORMS_STA REBUILD;

COMMENT ON COLUMN ML_WAVEFORMS.WAVEFORMID IS 'waveform id';
COMMENT ON COLUMN ML_WAVEFORMS.ARID IS 'arrival id';
COMMENT ON COLUMN ML_WAVEFORMS.TIMEA IS 'automatic onset time';
COMMENT ON COLUMN ML_WAVEFORMS.TIMELEB IS 'real time asignem by analyst (possible retimming)';
COMMENT ON COLUMN ML_WAVEFORMS.IPHASE IS 'initial wave type label from StaPro';
COMMENT ON COLUMN ML_WAVEFORMS.IPHASECL IS 'initial wave type class';
COMMENT ON COLUMN ML_WAVEFORMS.IPHASECLNUM IS 'initial wave type class numerical code';
COMMENT ON COLUMN ML_WAVEFORMS.PHASE IS 'phase label from LEB';
COMMENT ON COLUMN ML_WAVEFORMS.PHASECL IS 'phase class LEB';
COMMENT ON COLUMN ML_WAVEFORMS.PHASECLNUM IS 'phase class LEB numerical code';
COMMENT ON COLUMN ML_WAVEFORMS.SOURCE IS 'A - automatic phase family type remained after association, H - automatic phase family changed by analyst, M - manually added by analysts (no automatice detection)';
COMMENT ON COLUMN ML_WAVEFORMS.STA IS 'station';
COMMENT ON COLUMN ML_WAVEFORMS.CHANNELS IS 'coma separated list of channels';
COMMENT ON COLUMN ML_WAVEFORMS.SAMPRATE IS 'sampling rate';
COMMENT ON COLUMN ML_WAVEFORMS.STARTTIME IS 'start time of stored waveform';
COMMENT ON COLUMN ML_WAVEFORMS.ENDTIME IS 'end time of stored waveform';
COMMENT ON COLUMN ML_WAVEFORMS.NSAMP IS 'number of samples stored';
COMMENT ON COLUMN ML_WAVEFORMS.CALIB IS 'calibration values in the same order as CHANNE:S as 4Byte floats';
COMMENT ON COLUMN ML_WAVEFORMS.SAMPLES IS 'binary blobs of calibrated samples of channels as 4byte floats in the same order as in CHANNELS';


-- use in a trigger to autoincrement the sequence
CREATE OR REPLACE TRIGGER WAVEFORM_ID_INCREMENT2
BEFORE INSERT ON ML_WAVEFORMS
FOR EACH ROW
BEGIN
  SELECT SEQ_WAVEFORM_ID2.NEXTVAL
  INTO   :new.WAVEFORMID
  FROM   dual;
END;
/


