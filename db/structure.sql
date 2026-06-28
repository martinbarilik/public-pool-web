\restrict WWClgTRkJHXgc3zcP75BAi4bwaskMinJU4BDfIJgZO7jGdedyS6lUhHU0IiNlrq

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg13+1)
-- Dumped by pg_dump version 18.4 (Debian 18.4-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: chart_datas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chart_datas (
    id bigint NOT NULL,
    worker_id bigint NOT NULL,
    label timestamp(6) without time zone,
    data numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: chart_data_p7d_views; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.chart_data_p7d_views AS
 WITH numbered_data AS (
         SELECT date_trunc('second'::text, chart_datas.label) AS label,
            chart_datas.worker_id,
            (chart_datas.data)::double precision AS data,
            row_number() OVER (PARTITION BY chart_datas.worker_id ORDER BY chart_datas.label) AS row_num
           FROM public.chart_datas
          WHERE (chart_datas.label >= (now() - '7 days'::interval))
        ), grouped_data AS (
         SELECT numbered_data.worker_id,
            floor((((numbered_data.row_num - 1) / 168))::double precision) AS group_num,
            min(numbered_data.label) AS group_start_time,
            avg(numbered_data.data) AS avg_data,
            count(*) AS data_points
           FROM numbered_data
          GROUP BY numbered_data.worker_id, (floor((((numbered_data.row_num - 1) / 168))::double precision))
        )
 SELECT group_start_time AS interval_label,
    worker_id,
    avg_data,
    data_points,
    group_num
   FROM grouped_data
  ORDER BY group_start_time, worker_id;


--
-- Name: chart_data_pt1h_views; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.chart_data_pt1h_views AS
 WITH numbered_data AS (
         SELECT date_trunc('second'::text, chart_datas.label) AS label,
            chart_datas.worker_id,
            (chart_datas.data)::double precision AS data,
            row_number() OVER (PARTITION BY chart_datas.worker_id ORDER BY chart_datas.label) AS row_num
           FROM public.chart_datas
          WHERE (chart_datas.label >= (now() - '01:00:00'::interval))
        ), grouped_data AS (
         SELECT numbered_data.worker_id,
            floor(((numbered_data.row_num - 1))::double precision) AS group_num,
            min(numbered_data.label) AS group_start_time,
            avg(numbered_data.data) AS avg_data,
            count(*) AS data_points
           FROM numbered_data
          GROUP BY numbered_data.worker_id, (floor(((numbered_data.row_num - 1))::double precision))
        )
 SELECT group_start_time AS interval_label,
    worker_id,
    avg_data,
    data_points,
    group_num
   FROM grouped_data
  ORDER BY group_start_time, worker_id;


--
-- Name: chart_data_pt24h_views; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.chart_data_pt24h_views AS
 WITH numbered_data AS (
         SELECT date_trunc('second'::text, chart_datas.label) AS label,
            chart_datas.worker_id,
            (chart_datas.data)::double precision AS data,
            row_number() OVER (PARTITION BY chart_datas.worker_id ORDER BY chart_datas.label) AS row_num
           FROM public.chart_datas
          WHERE (chart_datas.label >= (now() - '24:00:00'::interval))
        ), grouped_data AS (
         SELECT numbered_data.worker_id,
            floor((((numbered_data.row_num - 1) / 24))::double precision) AS group_num,
            min(numbered_data.label) AS group_start_time,
            avg(numbered_data.data) AS avg_data,
            count(*) AS data_points
           FROM numbered_data
          GROUP BY numbered_data.worker_id, (floor((((numbered_data.row_num - 1) / 24))::double precision))
        )
 SELECT group_start_time AS interval_label,
    worker_id,
    avg_data,
    data_points,
    group_num
   FROM grouped_data
  ORDER BY group_start_time, worker_id;


--
-- Name: chart_data_pt4h_views; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.chart_data_pt4h_views AS
 WITH numbered_data AS (
         SELECT date_trunc('second'::text, chart_datas.label) AS label,
            chart_datas.worker_id,
            (chart_datas.data)::double precision AS data,
            row_number() OVER (PARTITION BY chart_datas.worker_id ORDER BY chart_datas.label) AS row_num
           FROM public.chart_datas
          WHERE (chart_datas.label >= (now() - '04:00:00'::interval))
        ), grouped_data AS (
         SELECT numbered_data.worker_id,
            floor((((numbered_data.row_num - 1) / 4))::double precision) AS group_num,
            min(numbered_data.label) AS group_start_time,
            avg(numbered_data.data) AS avg_data,
            count(*) AS data_points
           FROM numbered_data
          GROUP BY numbered_data.worker_id, (floor((((numbered_data.row_num - 1) / 4))::double precision))
        )
 SELECT group_start_time AS interval_label,
    worker_id,
    avg_data,
    data_points,
    group_num
   FROM grouped_data
  ORDER BY group_start_time, worker_id;


--
-- Name: chart_datas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chart_datas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chart_datas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chart_datas_id_seq OWNED BY public.chart_datas.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id bigint NOT NULL,
    best_difficulty numeric,
    period character varying DEFAULT '1.hour'::character varying NOT NULL,
    host character varying DEFAULT '127.0.0.1'::character varying NOT NULL,
    port character varying DEFAULT '2019'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    network_difficulty numeric DEFAULT 0.0 NOT NULL,
    network_hash numeric DEFAULT 0.0 NOT NULL,
    block_height numeric DEFAULT 0.0 NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying,
    best_difficulty numeric DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: workers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workers (
    id bigint NOT NULL,
    name character varying,
    user_id bigint NOT NULL,
    session_id character varying,
    best_difficulty numeric,
    hash_rate numeric,
    start_time timestamp(6) without time zone,
    last_seen timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: workers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workers_id_seq OWNED BY public.workers.id;


--
-- Name: chart_datas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chart_datas ALTER COLUMN id SET DEFAULT nextval('public.chart_datas_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: workers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workers ALTER COLUMN id SET DEFAULT nextval('public.workers_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: chart_datas chart_datas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chart_datas
    ADD CONSTRAINT chart_datas_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- Name: index_chart_datas_on_worker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chart_datas_on_worker_id ON public.chart_datas USING btree (worker_id);


--
-- Name: index_workers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workers_on_user_id ON public.workers USING btree (user_id);


--
-- Name: workers fk_rails_809fcde244; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT fk_rails_809fcde244 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: chart_datas fk_rails_c179bdb7b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chart_datas
    ADD CONSTRAINT fk_rails_c179bdb7b9 FOREIGN KEY (worker_id) REFERENCES public.workers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict WWClgTRkJHXgc3zcP75BAi4bwaskMinJU4BDfIJgZO7jGdedyS6lUhHU0IiNlrq

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260628082645'),
('20260625061355'),
('20260625060115'),
('20260624193113'),
('20260615191138'),
('20260612000001'),
('20250831140000'),
('20250831130000'),
('20250831120000'),
('20250831110000'),
('20250306141403'),
('20250225201245'),
('20250224180548'),
('20250224180442');

