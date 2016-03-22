CREATE FUNCTION plsh_handler() RETURNS language_handler
    AS '$libdir/plsh'
    LANGUAGE C;

CREATE FUNCTION plsh_inline_handler(internal) RETURNS void
    AS '$libdir/plsh'
    LANGUAGE C;

CREATE FUNCTION plsh_validator(oid) RETURNS void
    AS '$libdir/plsh'
    LANGUAGE C;

CREATE LANGUAGE plshu
    HANDLER plsh_handler
    INLINE plsh_inline_handler
    VALIDATOR plsh_validator;

COMMENT ON LANGUAGE plshu IS 'PL/shU untrusted procedural language';