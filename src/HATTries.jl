

module HATTries

include("../deps/deps.jl")


export HATTrie

type HATTrie <: Associative{String, UInt}
    ptr::Ptr{Void}
end

function HATTrie()
    ht = HATTrie(ccall((:hattrie_create, libhattrie), Ptr{Void}, ()))

    finalizer(ht, _free)
    return ht
end


function _free(ht::HATTrie)
    ccall((:hattrie_free, libhattrie), Void, (Ptr{Void},), ht.ptr)
end


function Base.get!(ht::HATTrie, key::Ptr{UInt8}, keylen::Integer, default_::Integer)
    valptr = ccall((:hattrie_get, libhattrie), Ptr{UInt},
                   (Ptr{Void}, Ptr{UInt8}, Csize_t), ht.ptr, key, keylen)
    default = UInt(default_)
    val = unsafe_load(valptr)
    if val == 0
        unsafe_store!(valptr, default)
        return default
    else
        return val
    end
end


function Base.get!(ht::HATTrie, key::String, default_::Integer)
    return get!(ht, pointer(key), length(key), default_)
end


function Base.haskey(ht::HATTrie, key::Ptr{UInt8}, keylen::Integer)
    valptr = ccall((:hattrie_tryget, libhattrie), Ptr{UInt},
                   (Ptr{Void}, Ptr{UInt8}, Csize_t),
                   ht.ptr, key, keylen)
    return valptr != C_NULL
end


function Base.haskey(ht::HATTrie, key::String)
    return haskey(ht, pointer(key), length(key))
end


function Base.get(ht::HATTrie, key::Ptr{UInt8}, keylen::Integer, default_::Integer)
    valptr = ccall((:hattrie_tryget, libhattrie), Ptr{UInt},
                   (Ptr{Void}, Ptr{UInt8}, Csize_t),
                   ht.ptr, key, keylen)
    default = UInt(default_)
    return valptr == C_NULL ? default : unsafe_load(valptr)
end


function Base.get(ht::HATTrie, key::String, default_::Integer)
    return get(ht, pointer(key), length(key), default_)
end


function Base.getindex(ht::HATTrie, key::Ptr{UInt8}, keylen::Integer)
    valptr = ccall((:hattrie_tryget, libhattrie), Ptr{UInt},
                   (Ptr{Void}, Ptr{UInt8}, Csize_t),
                   ht.ptr, key, keylen)
    if valptr == C_NULL
        skey = String(unsafe_wrap(Array, key, keylen, false))
        throw(KeyError(skey))
    else
        return unsafe_load(valptr)
    end
end


function Base.getindex(ht::HATTrie, key::String)
    return getindex(ht, pointer(key), length(key))
end


function Base.setindex!(ht::HATTrie, val_::Integer, key::Ptr{UInt8},
                        keylen::Integer)
    valptr = ccall((:hattrie_get, libhattrie), Ptr{UInt},
                   (Ptr{Void}, Ptr{UInt8}, Csize_t), ht.ptr, key, keylen)

    val = UInt(val_)
    unsafe_store!(valptr, val)
    return val
end


function Base.setindex!(ht::HATTrie, val_::Integer, key::String)
    setindex!(ht, val_, pointer(key), length(key))
end


function Base.length(ht::HATTrie)
    return Int(ccall((:hattrie_size, libhattrie), Csize_t, (Ptr{Void},), ht.ptr))
end


function Base.empty!(ht::HATTrie)
    ccall((:hattrie_clear, libhattrie), Void, (Ptr{Void},), ht.ptr)
end


function Base.delete!(ht::HATTrie, key::Ptr{UInt8}, keylen::Integer)
    ret = ccall((:hattrie_del, libhattrie), Cint,
                (Ptr{Void}, Ptr{UInt8}, Csize_t),
                ht.ptr, key, keylen)
    if ret != 0
        skey = String(unsafe_wrap(Array, key, keylen, false))
        throw(KeyError(skey))
    end
end


function Base.delete!(ht::HATTrie, key::String)
    delete!(ht, pointer(key), length(key))
end


type HATTrieIter
    ptr::Ptr{Void}
end


function _free_iterator(iter::HATTrieIter)
    ccall((:hattrie_iter_free, libhattrie), Void, (Ptr{Void},), iter.ptr)
end


function Base.start(ht::HATTrie)
    ptr = ccall((:hattrie_iter_begin, libhattrie),
                Ptr{Void}, (Ptr{Void}, Bool),
                ht.ptr, false)
    iter = HATTrieIter(ptr)
    finalizer(iter, _free_iterator)
    return iter
end


function Base.next(ht::HATTrie, iter::HATTrieIter)
    keylenptr = Ref(UInt(0))
    keyptr = ccall((:hattrie_iter_key, libhattrie), Ptr{UInt8},
                   (Ptr{Void}, Ptr{Csize_t}), iter.ptr, keylenptr)
    key = String(unsafe_wrap(Array, keyptr, keylenptr.x, false))

    valptr = ccall((:hattrie_iter_val, libhattrie), Ptr{UInt},
                   (Ptr{Void},), iter.ptr)
    val = unsafe_load(valptr)

    ccall((:hattrie_iter_next, libhattrie), Void, (Ptr{Void},), iter.ptr)

    return ((key, val), iter)
end


function Base.done(ht::HATTrie, iter::HATTrieIter)
    return ccall((:hattrie_iter_finished, libhattrie), Bool, (Ptr{Void},),
                 iter.ptr)
end


# TODO: sorted iteration

end # module HATTries



