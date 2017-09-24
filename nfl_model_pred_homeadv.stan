data {
  int nteams;
  int ngames;
  vector[nteams] prior_score;
  int team1[ngames];
  int team2[ngames];
  vector[ngames] score1;
  vector[ngames] score2;
  real df;
  
  int newgames;
  int newteam1[newgames];
  int newteam2[newgames];
  
}

transformed data {
  vector[ngames] dif;
  vector[ngames] sqrt_dif;
  dif = score1 - score2;
  for (i in 1:ngames)
    sqrt_dif[i] = (step(dif[i]) - .5)*sqrt(fabs(dif[i]));
}

parameters {
  real b;
  real sigma_a;
  real sigma_y;
  vector[nteams] a;
  real home_adv;
}

model {
  home_adv ~ student_t(3,0,1);
  a ~ normal(b*prior_score, sigma_a);
  for (i in 1:ngames)
    sqrt_dif[i] ~ student_t(df, a[team1[i]]-a[team2[i]] + home_adv, sigma_y);
}

generated quantities {
  vector[newgames] new_dif;
  vector[newgames] sqrt_new_dif;
  
  for (i in 1:newgames) {
    sqrt_new_dif[i] = student_t_rng(df,a[newteam1[i]]-a[newteam2[i]] + home_adv,sigma_y);
    new_dif[i] = (step(sqrt_new_dif[i])-0.5)*sqrt_new_dif[i]*sqrt_new_dif[i];    
  }
  
}
