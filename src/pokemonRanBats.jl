__precompile__()

module pokemonRanBats

##########################################################################################

#### 	REQUIREMENTS

##########################################################################################

using StatsBase
using Images
using ImageView

##########################################################################################

#### 	EXPORTS

##########################################################################################

export createTeam!
export Pokemon

##########################################################################################

#### 	CONSTANTS

##########################################################################################

const dataDir = joinpath(dirname(@__DIR__), "data")

const targetStrength = 3.5

const tierToValue = Dict(
    "S" => 5,
    "A" => 4,
    "B" => 3,
    "C" => 2,
    "D" => 1
)

const alltypes = Dict(
    "normal" => Dict("fighting" => 2.0, "ghost" => 0),
    "fire" => Dict("fire" => 0.5, "water" => 2.0, "grass" => 0.5, "ice" => 0.5, "ground" => 2.0, "bug" => 0.5, "rock" => 2.0, "steel" => 0.5, "fairy" => 0.5),
    "water" => Dict("fire" => 0.5, "water" => 0.5, "electric" => 2.0, "grass" => 2.0, "ice" => 0.5, "steel" => 0.5),
    "electric" => Dict("electric" => 0.5, "ground" => 2.0, "flying" => 0.5, "steel" => 0.5),
    "grass" => Dict("fire" => 2.0, "water" => 0.5, "electric" => 0.5, "grass" => 0.5, "ice" => 2.0, "poison" => 2.0, "ground" => 0.5, "flying" => 2.0, "bug" => 2.0),
    "ice" => Dict("fire" => 2.0, "ice" => 0.5, "fighting" => 2.0, "rock" => 2.0, "steel" => 2.0),
    "fighting" => Dict("flying" => 2.0, "psychic" => 2.0, "bug" => 0.5, "rock" => 0.5, "dark" => 0.5, "fairy" => 2.0),
    "poison" => Dict("grass" => 0.5, "fighting" => 0.5, "poison" => 0.5, "ground" => 2.0, "psychic" => 2.0, "bug" => 0.5, "fairy" => 0.5),
    "ground" => Dict("water" => 2.0, "electric" => 0.0, "grass" => 2.0, "ice" => 2.0, "poison" => 1/2.0, "rock" => 0.5),
    "flying" => Dict("electric" => 2.0, "grass" => 0.5, "ice" => 2.0, "fighting" => 0.5, "ground" => 0.0, "bug" => 0.5, "rock" => 2.0),
    "psychic" => Dict("fighting" => 0.5, "psychic" => 0.5, "bug" => 2.0, "ghost" => 2.0, "dark" => 2.0),
    "bug" => Dict("fire" => 2.0, "grass" => 0.5, "fighting" => 0.5, "ground" => 0.5, "flying" => 2.0, "rock" => 2.0),
    "rock" => Dict("normal" => 0.5, "fire" => 0.5, "water" => 2.0, "grass" => 2.0, "fighting" => 2.0, "poison" => 0.5, "ground" => 2.0, "flying" => 0.5, "steel" => 2.0),
    "ghost" => Dict("normal" => 0.0, "fighting" => 0.0, "poison" => 0.5, "bug" => 0.5, "ghost" => 2.0, "dark" => 2.0),
    "dragon" => Dict("fire" => 0.5, "water" => 0.5, "electric" => 0.5, "grass" => 0.5, "ice" => 2.0, "dragon" => 2.0, "fairy" => 2.0),
    "dark" => Dict("fighting" => 2.0, "psychic" => 0.0, "bug" => 2.0, "ghost" => 0.5, "dark" => 0.5, "fairy" => 2.0),
    "steel" => Dict("normal" => 0.5, "fire" => 2.0, "grass" => 0.5, "ice" => 0.5, "fighting" => 2.0, "poison" => 0.0, "ground" => 2.0, "flying" => 0.5, "psychic" => 0.5, "bug" => 0.5, "rock" => 0.5, "dragon" => 0.5, "steel" => 0.5, "fairy" => 0.5),
    "fairy" => Dict("fighting" => 0.5, "poison" => 2.0, "bug" => 0.5, "dragon" => 0.0, "dark" => 0.5, "steel" => 2.0)
)

##########################################################################################

#### 	STRUCTS

##########################################################################################

struct Pokemon
    name::String
    type1::String
    type2::String
    resistances::Vector{String}
    weaknesses::Vector{String}
    tier::String
end

mutable struct Team
    mega::Pokemon
    rest::Vector{Pokemon}
    strength::Float64
end

##########################################################################################

#### 	CONSTEUCTORS

##########################################################################################

Pokemon(name, type1, type2, tier) = Pokemon(name, type1, type2, getResistance(type1, type2), getWeakness(type1, type2), tier)
Pokemon(name, type1, type2) = Pokemon(name, type1, type2, "B")
Pokemon(name, type1) = Pokemon(name, type1, "null", "B")

Team(mega, rest) = Team(mega, rest, targetStrength)
Team(mega) = Team(mega, [], targetStrength)

##########################################################################################

#### 	TYPE FUNCTIONS

##########################################################################################

#Returns an array of defensive weaknesses
function getWeakness(type1, type2 = "null")
    type1Weaknesses = [k for (k,v) in get(alltypes, type1, Dict()) if v == 2]
    type1Resistances = [k for (k,v) in get(alltypes, type1, Dict()) if v == 0.5]
    type1Immunities = [k for (k,v) in get(alltypes, type1, Dict()) if v == 0]
    type2Weaknesses = [k for (k,v) in get(alltypes, type2, Dict()) if v == 2]
    type2Resistances = [k for (k,v) in get(alltypes, type2, Dict()) if v == 0.5]
    type2Immunities = [k for (k,v) in get(alltypes, type2, Dict()) if v == 0]
    totalImmunities = union(type1Immunities, type2Immunities)
    return setdiff(union(setdiff(type1Weaknesses, type2Resistances), setdiff(type2Weaknesses, type1Resistances)), totalImmunities)
end

#Returns an array of defensive resistances
function getResistance(type1, type2 = "null")
    type1Weaknesses = [k for (k,v) in get(alltypes, type1, Dict()) if v == 2]
    type1Resistances = [k for (k,v) in get(alltypes, type1, Dict()) if v == 0.5]
    type1Immunities = [k for (k,v) in get(alltypes, type1, Dict()) if v == 0]
    type2Weaknesses = [k for (k,v) in get(alltypes, type2, Dict()) if v == 2]
    type2Resistances = [k for (k,v) in get(alltypes, type2, Dict()) if v == 0.5]
    type2Immunities = [k for (k,v) in get(alltypes, type2, Dict()) if v == 0]
    totalImmunities = union(type1Immunities, type2Immunities)
    return union(totalImmunities, union(setdiff(type2Resistances, type1Weaknesses), setdiff(type1Resistances, type2Weaknesses)))
end

function initEmptyTypeDict()
    return Dict(("normal", "fire", "water", "electric", "grass", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dragon", "dark", "steel", "fairy") .=> 0)
end

#Creates a typeDictionary by comparing strength to weaknesses
#3 Resistances and 2 weaknesses for a type means the type gets a value of 3 - 2 = 1
#Basically the Marriland Team Builder
function getTeamDict(team::Team)
    teamDict = initEmptyTypeDict()
    for poke in vcat(team.mega, team.rest)
        [teamDict[res] += 1 for res in poke.resistances]
        [teamDict[weak] -= 1 for weak in poke.weaknesses]
    end
    return teamDict
end

#Calculates how well pokemon fits into the team corresponding to teamDict
function getTypeScore(pokemon::Pokemon, teamDict)
    score = 0
    for res in pokemon.resistances
        if teamDict[res] <= 0
            #giving a bonus if we go from 0 or fewer resistances to 1
            score += 1
        end
        if teamDict[res] >= 2
            #giving a penalty if we go from 2 or more resistances to even more
            score -= 1
        end
    end

    for weak in pokemon.weaknesses
        if teamDict[weak] >= 2
            #giving a bonus if we go from 2 or more resistances to fewer
            score += 1
        end
        if teamDict[weak] <= 1
            #giving a penalty if we go from 1 or fewer resistances to even fewer
            score -= 1
        end
    end
    return score
end

##########################################################################################

#### 	STRENGTH/TIER FUNCTIONS

##########################################################################################

#Updates strength of Team by calculating the average strength of each Pokemon
function updateStrength!(team::Team)
    newStrength = 0
    for pokemon in team.rest
        newStrength += tierToValue[pokemon.tier]
    end
    team.strength = newStrength / length(team.rest)
end

#Creates a dictionary of multipliers depending on how close the strength corresponding to a tier is to searchStrength
#Closest strength gets the highest multiplier, farthest the lowest
function getStrengthMultiplierDict(searchStrength)
    strengthValues = [1, 2, 3, 4, 5]
    sort = sortperm(abs.(strengthValues .- searchStrength))

    return Dict(
        [k for (k, v) in tierToValue if v == sort[1]][1] => 4,
        [k for (k, v) in tierToValue if v == sort[2]][1] => 2,
        [k for (k, v) in tierToValue if v == sort[3]][1] => 1,
        [k for (k, v) in tierToValue if v == sort[4]][1] => 0.5,
        [k for (k, v) in tierToValue if v == sort[5]][1] => 0.25,
    )
end

##########################################################################################

#### 	TEAM FUNCTIONS

##########################################################################################

#Returns an array of multipliers
#Example for maxMult = 4.0 and length = 5:
#[0.25, 0.4, 1, 2.5, 4.0]
function getMults(length; maxMult = 4.0)
    mults = []
    for i = 1 : floor(length / 2)
        append!(mults, 1 + (maxMult - 1) * i / floor(length / 2))
    end
    if length % 2 == 1
        return mults = vcat(reverse(1 ./ mults), [1], mults)
    else
        return mults = vcat(reverse(1 ./ mults), mults)
    end
end

#Adds a pokemon from box to team. Only pokemon that aren't in the team already can be added
function addPokemon!(team::Team, box::Vector)
    updateStrength!(team)
    possibles = setdiff(box, team.rest)
    teamDict = getTeamDict(team)
    #mirroring teamStrength on targetStrength, ex. teamStrength = 3 and targetStrength = 4 => searchStrength = 5
    searchStrength = 2 * targetStrength - team.strength
    strengthDict = getStrengthMultiplierDict(searchStrength)
    #create the type score for every pokemon in possibles, then search possibles according to their score
    typeScores = []
    for p in possibles
        append!(typeScores, getTypeScore(p, teamDict))
    end
    sortPossibles = possibles[sortperm(typeScores)]
    sort!(typeScores)
    #get array of multipliers and multiply the score multipliers with the tier multipliers
    mults = getMults(length(sortPossibles))

    for i = 1 : length(sortPossibles)
        mults[i] = mults[i] .* strengthDict[sortPossibles[i].tier]
    end
    #normalize multipliers so that they add up to 1
    mults = mults ./ sum(mults)

    #draw one possible pokemon and add it to the team
    new = sample(sortPossibles, Weights(mults))
    team.rest = vcat(team.rest, new)
    updateStrength!(team)
end

#Creates a team around mega with Pokemon from box
function createTeam(mega::Pokemon, box::Vector; showImage = true, saveName = "")
    t = Team(mega)
    for i = 1 : 5
        addPokemon!(t, box)
    end

    if showImage
        img = mosaic(
            load(joinpath(dataDir, "megaImages", t.mega.name * ".png")),
            load(joinpath(dataDir, "pokemonImages", t.rest[1].name * ".png")),
            load(joinpath(dataDir, "pokemonImages", t.rest[2].name * ".png")),
            load(joinpath(dataDir, "pokemonImages", t.rest[3].name * ".png")),
            load(joinpath(dataDir, "pokemonImages", t.rest[4].name * ".png")),
            load(joinpath(dataDir, "pokemonImages", t.rest[5].name * ".png"));
            nrow = 2
            )
            imshow(img)
            if saveName != ""
                save(saveName * ".png", img)
            end
    end
    return t
end

end # module
