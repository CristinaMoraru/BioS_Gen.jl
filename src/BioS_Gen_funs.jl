
export my_mkpath, rm_mkpaths, rm_path, getFileName, getFileExtention
export write_close, write_error
export ispresent, dir_cont, filter_by_extension!
export lapplyDf!, convert_col_to_string!, derepDf, derepDf!
export generate_range, df2dict


### files and folders

"""
    # my_mkpath(paths::Vector{String})
    It takes a Vector of folder paths (as Strings) and creates each folder (recursively).

    ## Arguments
    - paths::Vector{String}: A vector with String elements, each representing a path toward a folder.

    ## Returns
    - nothing
"""
function my_mkpath(paths::Vector{String})
    for path in paths
        mkpath(path)
    end

    return nothing
end  


"""
    rm_path(path::String)
    It checks if a path exists and removes it.
"""
function rm_path(path::String)
    if ispath(path)
        rm(path, recursive=true)
    end
    return nothing
end

"""
    rm_path(path::String)
    It accepts a vector of paths (String type) and checks for each element if the path exists and removes it.
"""
function rm_path(path::Vector{String})
    for p in path
        if ispath(p)
            rm(p, recursive=true)
        end
    end
    return nothing
end

"""
    rm_mkpaths(paths::Vector{String})
    It accepts a vector of folder paths and it creates each of them, after removing them if they already exist.
"""
function rm_mkpaths(paths::Vector{String})
    for path in paths
        rm_path(path)
        mkpath(path)
    end

    return nothing
end

"""
    getFileName(path::String)
    It takes a file path (as string) and returns the filename (without the extension).
"""
getFileName = first ∘ splitext ∘ basename


"""
    getFileExtention(path::String)
    It takes a file path (as string) and returns the extention of the file.
"""
getFileExtention = last ∘ splitext ∘ basename


"""
    write_close(path::String, content::String)
    It opens a file, writes a String inside, and then closes the file.

    ## Arguments
    - path::String: the path toward the file
    - content::String: the content of the file

    ## Returns
    - nothing
"""
function write_close(path::String, content::String)
    f = open(path, "w")
    write(f, content)
    close(f)

    return nothing
end


function write_error(exitcode::Int, err_p::String)
    if exitcode != 0
        write_close(err_p, exitcode)
    end
end

#####

"""
    ispresent(what::Regex, where::Tuple)
    Determines if a string is present somewhere (e.g. in a tuple or a vector)
"""
function ispresent(what::String, location::Union{Tuple, Vector}) 
    indices = findall(x -> occursin(what, x), location)
    if length(indices) == 0
        return false
    else
        return true
    end
end

"""
    ispresent(what::Regex, where::Tuple)
    Determines if a Symbol is present somewhere (e.g. in a tuple or a vector)
"""
function ispresent(what::Symbol, location::Union{Tuple, Vector}) 
    indices = findall(x -> occursin(what, x), location)
    if length(indices) == 0
        return false
    else
        return true
    end
end

"""
    dir_cont(inDir::String, allowed, T::DataType)
    This method takes as input a folder path and returns only those files that have the allowed extension. 
    ## Returns:
    The ouput is a vector of the given PathsDT type
"""	
function dir_cont(inDir::String, allowed, T::DataType)
    if (T <: PathsDT) == false
        error("$T is not a valid subtype of the abstract PathsDT type.")
    end

    inFiles = readdir(inDir; join = true) 
    inFiles = filter_by_extension!(inFiles, allowed)
    inFilesP = stringVect2Paths(inFiles, T)

    return inFilesP
end

"""
    filter_by_extension!(paths::Vector{String}, allowed::Union{Tuple, Vector})
    Checks in a vector of paths (String format) if the file extension is in a tuple/vector of allowed extensions. 
    If the extension is not allowed, it removes the path from paths. 
    The extensions need to be given with dor (e.g. ".fasta"). 
    It modifies the paths vector in place.
"""
function filter_by_extension!(paths::Vector{String}, allowed::Union{Tuple, Vector})
    for i in length(paths):-1:1
        if isfile(paths[i]) == false
            deleteat!(paths, i)
        else
            ext = getFileExtention(paths[i])
            if !ispresent(ext, allowed)
                deleteat!(paths, i)
            end
        end
    end

    return paths
end


#region DataFrame functions

"""
    lapplyDf!(df::DataFrame, colex::Symbol, colnew::Symbol, f::Function)
    It applies a function of each element of a column (colex) and stores the results in a new column (colnew) in the same dataframe. It modifies
    the dataframe in place. 
"""
function lapplyDf!(df::DataFrame, colex::Symbol, colnew::Symbol, f::Function)
    df[!, colnew] = Vector{String}(undef, nrow(df))   # the ! selector here creates a new column
    
    for row in 1:nrow(df)
        df[row, colnew] = f(df[row, colex])
    end

    return df
end

"""
    For each element in a column, it searches for the matching key in a dictionary and returns the value of the required field of the found struct. 
"""
function lapplyDf!(df::DataFrame, colex::Symbol, colnew::Symbol, d::Dict, field::Symbol)
    df[!, colnew] = Vector{String}(undef, nrow(df))   # the ! selector here creates a new column

    for row in 1:nrow(df)
        df[row, colnew] = getproperty(d[df[row, colex]], field)
    end

    return df
end



"""
    convert_col_to_string!(df::DataFrame, colex::Symbol)
    Dataframe columns can have special types of strings, to save space. However, many functions expect pure strings. This functions converts a columnn to String.
    It modifies the dataframe in place.
"""

function convert_col_to_string!(df::DataFrame, colex::Symbol)#, colnew::Symbol)
    df[!, :colnew] = Vector{String}(undef, nrow(df))
    for i in 1:nrow(df)
        df[i, :colnew] = String(df[i, colex])
    end
    select!(df, Not(colex))
    rename!(df, :colnew => colex)

    return df
end

"""
    derepDf(df::DataFrame, col::Symbol)
    It dereplicates a dataframe based on a certain column. It returns a new dataframe.
"""
function derepDf(df::DataFrame, col::Symbol)
    dfs = sort(df, col)
    for i in nrow(dfs):-1:2
        for j in 1:(i-1)
            if dfs[i, col] == dfs[j, col]
                deleteat!(dfs, i)
                break
            end
        end
    end

    return dfs
end

"""
    derepDf!(df::DataFrame, col::Symbol)
    It dereplicates a dataframe based on a certain column. It modifies the dataframe in place.
"""

function derepDf!(df::DataFrame, col::Symbol)
    sort!(df, col)
    for i in nrow(df):-1:2
        for j in 1:(i-1)
            if df[i, col] == df[j, col]
                deleteat!(df, i)
                break
            end
        end
    end

    return df
end

#endregion DataFrame functions


function generate_range(start::Int64, stop::Int64, step::Int64)
    vec_a = Vector{Int64}()
    vec_b = Vector{Int64}()

    a = start

    while a < stop
        push!(vec_a, a)
        b =  a + step -1

        if b >= stop
            b = stop
        end

        push!(vec_b, b)
        a = b 
    end

    return (vec_a, vec_b)
end

# I've updated the generate_range function, so that I can chose if the outputed ranges are overlaping or not
# once I bring MicroProber as package here, then I can remove the above function
function generate_range(start::Int64, stop::Int64, step::Int64, overlapping::Bool)
    vec_a = Vector{Int64}()
    vec_b = Vector{Int64}()

    a = start

    while a < stop
        push!(vec_a, a)
        b =  a + step -1

        if b >= stop
            b = stop
        end

        push!(vec_b, b)

        if overlapping
            a=b
        else
            a = b+1 
        end        
    end

    return (vec_a, vec_b)
end


function df2dict(df::DataFrame, key::Symbol, value::Symbol)
    d = Dict{String, String}()
    for i in 1:nrow(df)
        d[df[i, key]] = df[i, value]
    end

    return d
end