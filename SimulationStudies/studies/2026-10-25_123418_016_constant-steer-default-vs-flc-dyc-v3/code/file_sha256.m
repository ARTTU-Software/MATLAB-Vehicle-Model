function hash = file_sha256(path)
%file_sha256 - Calculate a file's SHA-256 content fingerprint
%   HASH = file_sha256(PATH) reads the file at the text path PATH in
%   binary chunks and returns a lowercase hexadecimal character vector.
%   It detects changed inputs/code without modifying the source file.
%
%   Example: from a study folder
%       hash = file_sha256('study_inputs.json');
%
%   See also study_scope, prepare_study

fid = fopen(path, 'rb');
assert(fid >= 0, 'Study:MissingFile', 'Cannot read %s', path);
cleanup = onCleanup(@() fclose(fid));
digest = java.security.MessageDigest.getInstance('SHA-256');
while ~feof(fid)
    bytes = fread(fid, 1024*1024, '*uint8');
    digest.update(typecast(bytes, 'int8'));
end
hash = lower(reshape(dec2hex(typecast(digest.digest(), 'uint8'), 2).', 1, []));
end
