<template>
  <div class="score-card">
    <h2>{{ player }}</h2>
    <p>Score: {{ score }}</p>
  </div>
</template>

<script>
export default {
  name: 'ScoreCard',
  props: ['player', 'score']
};
</script>

<style scoped>
.score-card {
  border: 1px solid #ccc;
  padding: 10px;
  margin: 10px;
  text-align: center;
}
</style>
