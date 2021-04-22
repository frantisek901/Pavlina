

// EXO HIGH.
treatments.exo_high = {

    sendResults: function () {
        var currentStage, previousStage,
        receivedData,
        sortedContribs,
        matching,
        ranking, groups, groupStats,
        noisyRanking, noisyGroups, noisyGroupStats,
        bars;

        currentStage = node.game.getCurrentGameStage();
        previousStage = node.game.plot.previous(currentStage);

        receivedData = node.game.memory.stage[previousStage]
            .selexec('key', '=', 'contrib');

        sortedContribs = receivedData
            .sort(sortContributions)
            .fetch();

        // Original Ranking (without noise).
        matching = doGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        ranking = matching.ranking;
        // Array of array of contributions objects.
        groups = matching.groups;
        // Compute average contrib and demand in each group.
        groupStats = computeGroupStats(groups);

        // Add Noise.
        receivedData = createNoise(receivedData, NOISE_HIGH);

        sortedContribs = receivedData
            .sort(sortNoisyContributions)
            .fetch();

        matching = doGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        noisyRanking = matching.ranking;
        // Array of array of contributions objects.
        noisyGroups = matching.groups;
        // Compute average contrib and demand in each group.
        noisyGroupStats = computeGroupStats(noisyGroups);

        // Bars for display in clients.
        bars = matching.bars;

        // Save to db, and sends results to players.
        finalizeRound(currentStage, bars,
                      groupStats, groups, ranking,
                      noisyGroupStats, noisyGroups, noisyRanking);
    }
};

// EXO LOW.
treatments.exo_low = {
    sendResults: function () {
        var currentStage, previousStage,
        receivedData,
        sortedContribs,
        matching,
        ranking, groups, groupStats,
        noisyRanking, noisyGroups, noisyGroupStats,
        bars;

        currentStage = node.game.getCurrentGameStage();
        previousStage = node.game.plot.previous(currentStage);

        receivedData = node.game.memory.stage[previousStage]
            .selexec('key', '=', 'contrib');
        
        if (!receivedData.db.length) {
            console.log('receivedData.db.length = 0!');
        }

        sortedContribs = receivedData
            .sort(sortContributions)
            .fetch();

        // Original Ranking (without noise).
        matching = doGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        ranking = matching.ranking;
        // Array of array of contributions objects.
        groups = matching.groups;
        // Compute average contrib and demand in each group.
        groupStats = computeGroupStats(groups);

        // Add Noise.
        receivedData = createNoise(receivedData, NOISE_LOW);

        sortedContribs = receivedData
            .sort(sortNoisyContributions)
            .fetch();

        matching = doGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        noisyRanking = matching.ranking;
        // Array of array of contributions objects.
        noisyGroups = matching.groups;
        // Compute average contrib and demand in each group.
        noisyGroupStats = computeGroupStats(noisyGroups);

        
        if (!noisyGroups.length) {
            console.log('noisyGroups.length = 0 !');
        }

        // Bars for display in clients.
        bars = matching.bars;

        // Save to db, and sends results to players.
        finalizeRound(currentStage, bars,
                      groupStats, groups, ranking,
                      noisyGroupStats, noisyGroups, noisyRanking);
    }
};

// EXO RANDO.
treatments.random = {
    sendResults: function () {
        var currentStage, previousStage,
        receivedData,
        sortedContribs,
        matching,
        ranking, groups, groupStats,
        noisyRanking, noisyGroups, noisyGroupStats,
        bars;

        currentStage = node.game.getCurrentGameStage();
        previousStage = node.game.plot.previous(currentStage);

        receivedData = node.game.memory.stage[previousStage]
            .selexec('key', '=', 'contrib');

        // Shuffle contributions randomly.
        sortedContribs = receivedData
            .shuffle()
            .fetch();

        // Original Ranking (without noise).
        matching = doGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        ranking = matching.ranking;
        // Array of array of contributions objects.
        groups = matching.groups;
        // Compute average contrib and demand in each group.
        groupStats = computeGroupStats(groups);

        // Add Noise (not in this case).
        noisyRanking = ranking;
        noisyGroups = groups;
        noisyGroupStats = groupStats;

        // Bars for display in clients.
        bars = matching.bars;

        // Save to db, and sends results to players.
        finalizeRound(currentStage, bars,
                      groupStats, groups, ranking,
                      noisyGroupStats, noisyGroups, noisyRanking);
    }
};

// EXO ENDO. TODO: Test it with at least 16 players.
treatments.endo = {

    sendResults: function() {
        var currentStage, previousStage,
        receivedData,
        sortedContribs,
        matching,
        ranking, groups, groupStats,
        noisyRanking, noisyGroups, noisyGroupStats,
        bars, compatibility;

        currentStage = node.game.getCurrentGameStage();
        previousStage = node.game.plot.previous(currentStage);

        receivedData = node.game.memory.stage[previousStage]
            .selexec('key', '=', 'contrib');

        if (!receivedData) {
            console.log('receivedData empty!');
            return;
        }

        sortedContribs = receivedData
            .sort(sortContributions)
            .fetch();

        matching = endoGroupMatching(sortedContribs);

        // Array of sorted player ids, from top to lowest contribution.
        ranking = matching.ranking;
        // Array of array of contributions objects.
        groups = matching.groups;
        // Compute average contrib and demand in each group.
        groupStats = computeGroupStats(groups);

        // Add Noise (not in this case).
        noisyRanking = ranking;
        noisyGroups = groups;
        noisyGroupStats = groupStats;

        // Bars for display in clients.
        bars = matching.bars;

        compatibility = matching.compatibility;

        // Save to db, and sends results to players.
        finalizeRound(currentStage, bars,
                      groupStats, groups, ranking,
                      noisyGroupStats, noisyGroups, noisyRanking,
                      compatibility);
    }
};

// BLACKBOX.
treatments.blackbox = treatments.exo_perfect;

// SINGAPORE.
treatments.singapore = treatments.exo_perfect;
