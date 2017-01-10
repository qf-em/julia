# This file is a part of Julia. License is MIT: http://julialang.org/license

function content(blob::GitBlob)
    return ccall((:git_blob_rawcontent, :libgit2), Ptr{Void}, (Ptr{Void},), blob.ptr)
end

function Base.length(blob::GitBlob)
    return ccall((:git_blob_rawsize, :libgit2), Int64, (Ptr{Void},), blob.ptr)
end

function isbinary(blob::GitBlob)
    bin_flag = ccall((:git_blob_isbinary, :libgit2), Int64, (Ptr{Void},), blob.ptr)
    return bin_flag == 1
end

function lookup(repo::GitRepo, oid::GitHash)
    blob_ptr_ptr = Ref{Ptr{Void}}(C_NULL)
    @check ccall((:git_blob_lookup, :libgit2), Cint,
                  (Ptr{Ptr{Void}}, Ptr{Void}, Ref{GitHash}),
                   blob_ptr_ptr, repo.ptr, Ref(oid))
    return GitBlob(blob_ptr_ptr[])
end

function Base.show(io::IO, blob::GitBlob)
    if !isbinary(blob)
        print(io, "Blob id: ", GitHash(blob.ptr), "\nContents:\n", content(blob))
    else
        print(io, "Blob id: ", GitHash(blob.ptr), "\nContents are binary.")
    end
end
