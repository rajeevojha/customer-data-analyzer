<template>
  <div id="app">
    <h1>Scoreboard</h1>
    <ScoreCard v-for="(score, player) in scores" :key="player" :player="player" :score="score" />
  </div>
</template>

<script>
import ScoreCard from './components/ScoreCard.vue';

export default {
  name: 'App',
  components: { ScoreCard },
  data() {
    return { scores: { aws: 0, gcp: 0, docker: 0 } };
  },
  async created() {
    this.updateScores();
    setInterval(this.updateScores, 2000);
  },
  methods: {
    async updateScores() {
      const response = await fetch('http://localhost:3001/scores');
      this.scores = await response.json();
    }
  }
};
</script>

<style>
#app { font-family: Arial, sans-serif; text-align: center; }
</style>
