var opponents = {};

opponents['randomStrategy'] = function () {
  function chooseAction() {
    return Math.round(Math.random());
  }
  return chooseAction;
}

opponents['alwaysDefect'] = function () {
  function chooseAction() {
    return 0;
  }
  return chooseAction;
}

opponents['alwaysCooperate'] = function () {
  function chooseAction() {
    return 1;
  }
  return chooseAction;
}

opponents['titForTat'] = function () {
  function chooseAction(me, opponent, t) {
    if (t == 0) return 1;
    return opponent[t-1];
  }
  return chooseAction;
}

opponents['titForTwoTats'] = function () {
  function chooseAction(me, opponent, t) {
    if (t <= 1) return 1;
    if (opponent[t-2] == 0 && opponent[t-1] == 0) return 0;
    return 1;
  }
  return chooseAction;
}
