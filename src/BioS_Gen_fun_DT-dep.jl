export stringVect2Paths, parse_vect, stringIntersect

"""
    stringVect2Paths(paths::Vector{String}, tp::DataType)
    This function converts a Vector of Strings into a Vector of concrete subtypes of PathsDT, e.g. FnaP or FaaP.
"""
function stringVect2Paths(paths::Vector{String}, tp::DataType)
    if (tp <: PathsDT) == false
        error("The type '$tp' is not valid parameter for this function. It must be a subtype of PathsDT.")
    end

    paths_out = Vector{tp}(undef, length(paths))
    for i in eachindex(paths)
        paths_out[i] = tp(paths[i])
    end
    return paths_out
end

"""
    parse_vect(dt::DataType, vals::Vector{SubString{String}})
    This function converts a Vector of Strings into a Vector of elements of another type. 
"""
function parse_vect(dt::DataType, vals::Vector{SubString{String}})
    retV = Vector{dt}(undef, length(vals))
    for i in 1:length(vals)
        retV[i] = parse(dt, vals[i])
    end
        
    return retV
end

"""
    stringIntersect(string1::String, string2::String)
    It takes two Strings representing a file path, extracts only the file names (without extention) and returns the common part of the strings (filenames).
"""
function stringIntersect(string1::String, string2::String)
    vec1 = getFileName(string1)
    vec2 = getFileName(string2)
    common = longestcommonsubstring(vec1, vec2)

    return common
end

