function hash = file_sha256(path)
%FILE_SHA256 Check that reviewed code/data have not changed between stages.
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
