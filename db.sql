CREATE TABLE asset (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    type        VARCHAR(100) NOT NULL,
    properties  JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_asset_name_type UNIQUE (name, type)
);

CREATE TABLE asset_dependency (
    dependent_asset_id  BIGINT NOT NULL,
    required_asset_id   BIGINT NOT NULL,

    PRIMARY KEY (dependent_asset_id, required_asset_id),

    CONSTRAINT fk_dependency_dependent
        FOREIGN KEY (dependent_asset_id)
        REFERENCES asset (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dependency_required
        FOREIGN KEY (required_asset_id)
        REFERENCES asset (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_no_self_dependency
        CHECK (dependent_asset_id <> required_asset_id)
);

-- Speeds up queries that find every asset depending on a given asset.
CREATE INDEX idx_asset_dependency_required
    ON asset_dependency (required_asset_id);

CREATE INDEX idx_asset_type
    ON asset (type);



dependent_asset_id → depends on → required_asset_id


INSERT INTO asset_dependency (dependent_asset_id, required_asset_id)
VALUES (10, 20);

SELECT dependent.*
FROM asset_dependency dependency
JOIN asset dependent
  ON dependent.id = dependency.dependent_asset_id
WHERE dependency.required_asset_id = :asset_id;
