--- List of extra functions that are not in use in Hound but might be useful in the future

--- Calculate stdev
function HOUND.StDev()
      local sum, sumsq, k = 0, 0, 0
      return function(n)
          sum, sumsq, k = sum + n, sumsq + n ^ 2, k + 1
          return math.sqrt((sumsq / k) - (sum / k) ^ 2)
      end
  end
    
--- K-means++ algorithm
-- <a href=https://rosettacode.org/wiki/K-means%2B%2B_clustering#Lua>Source of implementation</a>
-- @param data Datapoints
-- @param nclusters Number of clusters to create
-- @param init Initilization method. Valid values are ["kmeans++","random"]
-- @return centers (table)
-- @return cluster (table)
-- @return J loss value
function HOUND.Utils.Cluster.kmeans(data, nclusters, init)
    -- K-means Clustering
    --
    assert(nclusters > 0)
    assert(#data > nclusters)
    assert(init == "kmeans++" or init == "random")

    local diss = function(p, q)
      -- Computes the dissimilarity between points 'p' and 'q'
      return math.pow(p.x - q.x, 2) + math.pow(p.z - q.z, 2)
    end

    -- Initialization

    local centers = {} -- clusters centroids
    if init == "kmeans++" then
      local K = 1

      -- take one center c1, chosen uniformly at random from 'data'
      local i = math.random(1, #data)
      centers[K] = {x = data[i].x, z = data[i].z}
      local D = {}

      -- repeat until we have taken 'nclusters' centers
      while K < nclusters do
        -- take a new center ck, choosing a point 'i' of 'data' with probability
        -- D(i)^2 / sum_{i=1}^n D(i)^2

        local sum_D = 0.0
        for i = 1,#data do
          local min_d = D[i]
          local d = diss(data[i], centers[K])
          if min_d == nil or d < min_d then
              min_d = d
          end
          D[i] = min_d
          sum_D = sum_D + min_d
        end

        sum_D = math.random() * sum_D
        for i = 1,#data do
          sum_D = sum_D - D[i]

          if sum_D <= 0 then
            K = K + 1
            centers[K] = {x = data[i].x, z = data[i].z}
            break
          end
        end
      end
    elseif init == "random" then
      for k = 1,nclusters do
        local i = math.random(1, #data)
        centers[k] = {x = data[i].x, z = data[i].z}
      end
    end

    -- Lloyd K-means Clustering
    --
    local cluster = {} -- k-partition
    for i = 1,#data do cluster[i] = 0 end

    local J = function()
      -- Computes the loss value
      --
      local loss = 0.0
      for i = 1,#data do
        loss = loss + diss(data[i], centers[cluster[i]])
      end
      return loss
    end

    local updated = false
    repeat
      -- update k-partition
      --
      local card = {}
      for k = 1,nclusters do
        card[k] = 0.0
      end

      updated = false
      for i = 1,#data do
        local min_d, min_k = nil, nil

        for k = 1,nclusters do
          local d = diss(data[i], centers[k])

          if min_d == nil or d < min_d then
            min_d, min_k = d, k
          end
        end

        if min_k ~= cluster[i] then updated = true end

        cluster[i]  = min_k
        card[min_k] = card[min_k] + 1.0
      end
      -- print("update k-partition: ", J())

      -- update centers
      --
      for k = 1,nclusters do
        centers[k].x = 0.0
        centers[k].z = 0.0
      end

      for i = 1,#data do
        local k = cluster[i]

        centers[k].x = centers[k].x + (data[i].x / card[k])
        centers[k].z = centers[k].z + (data[i].z / card[k])
      end
      -- print("    update centers: ", J())
    until updated == false
    HOUND.Utils.Geo.setHeight(centers)
    return centers, cluster, J()
  end

--- convert contacts to centroieds for meanShift
-- @param contacts list of HOUND.Contact instances to evaluate
-- @return list of centrods where centroid = {p=&ltDCS pos&gt,r=&ltradius&gt,members={&ltHOUND.Contact&gt}}
function HOUND.Utils.Cluster.getCentroids(contacts)
    local centroids = {}
    -- populate centroids with all emitters
    for _,contact in ipairs(contacts) do
        local centroid = {
            p = contact.pos.p,
            r = contact.uncertenty_radius.r,
            members = {}
        }
        table.insert(centroid.members,contact)
        table.insert(centroids,centroid)
    end
    return centroids
end

--- Mean-shift algorithem to group radars to sites
-- http://www.chioka.in/meanshift-algorithm-for-the-rest-of-us-python/
-- @param contacts list of HOUND.Contact instances to cluster
-- @param[opt] iterations maximum nuber of itteratoins to run
-- @return List of centroieds {p=&ltDCS position&gt,r=&ltuncertenty radius&gt,members={&ltlist of HOUND.Contacts&gt}}
function HOUND.Utils.Cluster.meanShift(contacts,iterations)
    local kernel_bandwidth = 1000

    -- Helper functions
    local function gaussianKernel(distance,bandwidth)
        return (1/(bandwidth*l_math.sqrt(2*l_math.pi))) * l_math.exp(-0.5*((distance / bandwidth))^2)
    end

    local function findNeighbours(centroids,centroid,distance)
        if distance == nil then distance = centroid.r or kernel_bandwidth end
        local eligable = {}
        for _,candidate in ipairs(centroids) do
            local dist = l_mist.utils.get2DDist(candidate.p,centroid.p)
            if dist <= distance then
                table.insert(eligable,candidate)
            end
        end
        return eligable
    end

    local function compareCentroids(item1,item2)
        if item1.p.x ~= item2.p.x or item1.p.z ~= item2.p.z or item1.r ~= item2.r then return false end
        if HOUND.Length(item1.members) ~= HOUND.Length(item2.members) then return false end
        return true
    end

    local function compareCentroidLists(t1,t2)
        if HOUND.Length(t1) ~= HOUND.Length(t2) then return false end
        for _,item1 in ipairs(t1) do
            for _,item2 in ipairs(t2) do
                if not compareCentroids(item1,item2) then return false end
            end
        end
        return true
    end

    local function insertUniq(t,candidate)
        if type(t) ~= "table" or not candidate then return end
        for _,item in ipairs(t) do
            if not compareCentroids(item,candidate) then return end
        end
        env.info("Adding uniq: " .. candidate.p.x .. "/" .. candidate.p.z ..  " r=".. candidate.r .. " with " .. HOUND.Length(candidate.members) .. " members")
        table.insert(t,candidate)
    end

    -- Function starts here
    local centroids = {}
    -- populate centroids with all emitters
    for _,contact in ipairs(contacts) do
        local centroid = {
            p = contact.pos.p,
            r = l_math.min(contact.uncertenty_radius.r,kernel_bandwidth),
            members = {}
        }
        table.insert(centroid.members,contact)
        table.insert(centroids,centroid)
    end

    local past_centroieds = {}
    local converged = false
    local itr = 1
    while not converged do
        env.info("itteration " .. itr .. " starting with " .. HOUND.Length(centroids) .. " centroids")
        local new_centroids = {}
        for _,centroid in ipairs(centroids) do
            local neighbours = findNeighbours(centroids,centroid)
            local num_z = 0
            local num_x = 0
            local num_r = 0
            local denominator = 0
            local new_members = {}
            for _,neighbour in ipairs(neighbours) do
                local dist = l_mist.utils.get2DDist(neighbour.p,centroid.p)
                local weight = gaussianKernel(dist,centroid.r)
                num_z = num_z + (neighbour.p.z * weight)
                num_x = num_x + (neighbour.p.x * weight)
                num_r = num_r + (neighbour.r * weight)
                denominator = denominator + weight
                for _,memeber in ipairs(neighbour.members) do
                    table.insert(new_members,memeber)
                end
            end
            local new_centroid = l_mist.utils.deepCopy(centroid)
            new_centroid.p.x = num_x/denominator
            new_centroid.p.z = num_z/denominator
            new_centroid.r = num_r/denominator
            new_centroid.members = new_members
            insertUniq(new_centroids,new_centroid)
        end
        past_centroieds = centroids
        centroids = new_centroids
        itr = itr + 1
        converged = (compareCentroidLists(centroids,past_centroieds) or (iterations ~= nil and iterations <= itr))
    end
    env.info("meanShift() converged")
    return centroids
end

--- calculate ellipse errors
function HOUND.Contact.Emitter.calculateEllipseErrors(uncertenty_ellipse)
    if not uncertenty_ellipse.theta then return end
    local err = {}

    local sinTheta = l_math.sin(uncertenty_ellipse.theta)
    local cosTheta = l_math.cos(uncertenty_ellipse.theta)

    err.x = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*cosTheta), l_math.abs(-uncertenty_ellipse.major/2*sinTheta))
    err.z = l_math.max(l_math.abs(uncertenty_ellipse.minor/2*sinTheta), l_math.abs(uncertenty_ellipse.major/2*cosTheta))

    err.score = {}
    err.score.x = HOUND.Contact.Estimator.accuracyScore(err.x)
    err.score.z = HOUND.Contact.Estimator.accuracyScore(err.z)
    return err
end

--- Finallize position estimation Contact position
-- @local
-- @param estimatedPositions List of all estimated positions derrived fomr datapoints and intersections
-- @param[opt] converge Boolean, if True function will try and converge on best position
-- @return estimated position (DCS point)
function HOUND.Contact.Emitter.calculatePos(estimatedPositions,converge)
    if type(estimatedPositions) ~= "table" or HOUND.Length(estimatedPositions) == 0 then return end
    local pos = l_mist.getAvgPoint(estimatedPositions)
    if converge then
        local subList = estimatedPositions
        local subsetPos = pos
        while (HOUND.Length(subList) * HOUND.ELLIPSE_PERCENTILE) > 5 do
            local NewsubList = HOUND.Contact.Emitter.getDeltaSubsetPercent(subList,subsetPos,HOUND.ELLIPSE_PERCENTILE)
            subsetPos = l_mist.getAvgPoint(NewsubList)

            pos.x = pos.x + (subsetPos.x )
            pos.z = pos.z + (subsetPos.z )
            subList = NewsubList
        end
    end
    pos.y = land.getHeight({x=pos.x,y=pos.z})
    return pos
end