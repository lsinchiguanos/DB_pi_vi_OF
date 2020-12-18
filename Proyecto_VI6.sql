CREATE  TABLE usuario ( 
	id                   serial  NOT NULL ,
	cedula               varchar(15)  NOT NULL ,
	nombres              varchar(180)  NOT NULL ,
	apellidos            varchar(250)  NOT NULL ,
	fecha_nacimiento     varchar(80)  NOT NULL ,
	correo_electronico   varchar(180) DEFAULT 'info@gmail.com'  ,
	numero_celular       varchar(10) DEFAULT '0999999999'  ,
	direccion_vivienda   varchar(280) DEFAULT 'N/D'  ,
	username             varchar(30)  NOT NULL ,
	contrasenia          varchar(80)  NOT NULL ,
	tokens				 varchar(255)  DEFAULT 'N/D' ,
	rol                  varchar(2) DEFAULT 'CP'  ,
	estado               varchar(2) DEFAULT 'A'  ,
	fecha_creacion       timestamp without time zone DEFAULT now() ,
	fecha_modificacion   timestamp without time zone  ,
	CONSTRAINT pk_usuario_id PRIMARY KEY ( id ),
	CONSTRAINT idx_usuario UNIQUE ( cedula ) ,
	CONSTRAINT idx_usuario_username UNIQUE ( username ) 
 );

CREATE  TABLE adulto_mayor ( 
	id                   serial  NOT NULL ,
	id_usuario           integer  NOT NULL ,
	telefono_emergencia  varchar(10) DEFAULT '911'  ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	fecha_modificacion   timestamp without time zone  ,
	CONSTRAINT pk_adulto_mayor_id PRIMARY KEY ( id ),
	CONSTRAINT fk_adulto_mayor_usuario FOREIGN KEY ( id_usuario ) REFERENCES usuario( id )  
 );

CREATE  TABLE encargado ( 
	id                   serial  NOT NULL ,
	id_adulto_mayor      integer  NOT NULL ,
	id_usuario           integer  NOT NULL ,
	parentesco           varchar(180) DEFAULT 'N/D'  ,
	direccion_trabajo    varchar(280) DEFAULT 'N/D'  ,
	telefono_trabajo     varchar(10) DEFAULT '0999999999'  ,
	extensionc            varchar(10) DEFAULT '000'  ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	fecha_modificacion   timestamp without time zone   ,
	CONSTRAINT pk_encargado_id PRIMARY KEY ( id ),
	CONSTRAINT fk_encargado_adulto_mayor FOREIGN KEY ( id_adulto_mayor ) REFERENCES adulto_mayor( id )  ,
	CONSTRAINT fk_encargado_usuario FOREIGN KEY ( id_usuario ) REFERENCES usuario( id )  
 );

CREATE  TABLE horario ( 
	id                   serial  NOT NULL ,
	id_usuario           integer  NOT NULL ,
	tiempo_aviso         integer DEFAULT 30  ,
	fecha_creacion       date DEFAULT current_date  ,
	estado				 varchar(25) DEFAULT 'DActivo',
	fecha_modificacion   timestamp without time zone   ,
	CONSTRAINT pk_horario_id PRIMARY KEY ( id ),
	CONSTRAINT fk_horario_usuario FOREIGN KEY ( id_usuario ) REFERENCES usuario( id )  
 );

CREATE  TABLE horario_detalle ( 
	id                   serial  NOT NULL ,
	id_horario           integer  NOT NULL ,
	dia                  varchar(9)  NOT NULL ,
	numero_dia		     int NOT NULL,
	hora_inicio          varchar(5)  NOT NULL ,
	hora_fin             varchar(5)  NOT NULL ,
	descripcion          varchar(250) NOT NULL,
	estado               varchar(5) DEFAULT 'A'  ,
	color				 varchar(255) DEFAULT '#ffb6c1' ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	fecha_modificacion   timestamp without time zone   ,
	CONSTRAINT pk_calendario_id PRIMARY KEY ( id ),
	CONSTRAINT fk_horario_detalle_horario FOREIGN KEY ( id_horario ) REFERENCES horario( id )  
 );

CREATE  TABLE recordatorio ( 
	id                   serial  NOT NULL ,
	id_usuario_creador   integer  NOT NULL ,
	id_usuario_receptor  integer  NOT NULL ,
	titulo               varchar(250)  NOT NULL ,
	fecha_recordar       timestamp without time zone  NOT NULL ,
	fecha_limite		 timestamp without time zone NOT NULL,
	hora_recordatorio    varchar(5)  NOT NULL ,
	dia_duracion_aviso   integer DEFAULT 0  ,
	hora_frecuente_aviso integer DEFAULT 0  ,
	tiempo_pre_notificacion integer DEFAULT 30  ,
	tiempo_pos_aviso     integer DEFAULT 30  ,
	descripcion          varchar(500) DEFAULT 'ND'  ,
	estado               varchar(25) DEFAULT 'Activo',
	color				 varchar(255) DEFAULT '#ffb6c1',
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	fecha_modificacion   timestamp without time zone  ,
	CONSTRAINT pk_reordatorio_detalle_id PRIMARY KEY ( id ),
	CONSTRAINT fk_recordatorio_usuario FOREIGN KEY ( id_usuario_creador ) REFERENCES usuario( id )  
 );

CREATE  TABLE recordatorio_log ( 
	id                   serial  NOT NULL ,
	id_recordatorio      integer  NOT NULL ,
	fecha                varchar(15)  NOT NULL ,
	hora                 varchar(10)  NOT NULL ,
	accion               varchar(25)  NOT NULL ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	CONSTRAINT pk_recordatorio_log_id PRIMARY KEY ( id ),
	CONSTRAINT fk_recordatorio_log FOREIGN KEY ( id_recordatorio ) REFERENCES recordatorio( id )  
 );

CREATE  TABLE sesiones_log ( 
	id                   serial  NOT NULL ,
	id_usuario           integer  NOT NULL ,
	fecha                varchar(15)  NOT NULL ,
	hora                 varchar(10)  NOT NULL ,
	direccion_ip         varchar(15) DEFAULT '192.168.0.1'  ,
	accion               varchar(25) DEFAULT 'Inicio'  ,
	estado         		 varchar(25) DEFAULT 'Éxitoso'  ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	CONSTRAINT pk_sesiones_log_id PRIMARY KEY ( id ),
	CONSTRAINT fk_sesiones_log_usuario FOREIGN KEY ( id_usuario ) REFERENCES usuario( id )  
 );
 
 CREATE  TABLE dispositivo ( 
	id                   serial  NOT NULL ,
	id_usuario           integer  NOT NULL ,
	nombre               varchar(180)  NOT NULL ,
	descripcion          varchar(180)  NOT NULL ,
	ipv4                 varchar(15)  NOT NULL ,
	estado         		 varchar(25) DEFAULT 'Disponible'  ,
	fecha_creacion       timestamp without time zone DEFAULT now()  ,
	 fecha_modificacion  timestamp without time zone,
	CONSTRAINT pk_dispositivo_id PRIMARY KEY ( id ),
	CONSTRAINT fk_dispositivo_usuario FOREIGN KEY ( id_usuario ) REFERENCES usuario( id )  
 );

 CREATE OR REPLACE VIEW viewEncargados AS SELECT usr.id, usr.cedula, usr.apellidos, usr.nombres, usr.numero_celular, usr.correo_electronico, usr.direccion_vivienda,
	   enc.telefono_trabajo, enc.extensionc, enc.direccion_trabajo
	FROM public.encargado enc, public.usuario usr
		WHERE enc.id_usuario = usr.id and usr.rol like 'CP' and usr.estado like 'A';
		
CREATE OR REPLACE VIEW viewAdultoMayor AS SELECT ad.id_usuario, ad.id, usr.cedula, usr.apellidos, usr.nombres, usr.numero_celular, usr.correo_electronico, usr.direccion_vivienda,
	   ad.telefono_emergencia
	FROM public.usuario usr, public.adulto_mayor ad
		WHERE ad.id_usuario = usr.id and usr.rol like 'AD' and usr.estado like 'A';

CREATE OR REPLACE VIEW viewAdultosEncargado AS SELECT users.id as idUsuario, ad.id as idAdultomayor, concat(users.apellidos, ' ', users.nombres) AS apellidos, enc.id_usuario as idEncargado
	FROM public.usuario users, public.encargado enc, public.adulto_mayor ad
	WHERE users.rol = 'AD' and
		  ad.id_usuario = users.id and
		  enc.id_adulto_mayor = ad.id;

CREATE OR REPLACE VIEW viewAdultosUsers AS SELECT us.id as idUsuario, ad.id as idAdulto, concat(us.apellidos, ' ', us.nombres) AS apellidos
	FROM public.adulto_mayor ad, public.usuario us
		WHERE ad.id_usuario = us.id AND
			  us.estado = 'A' AND
			  us.rol = 'AD';

