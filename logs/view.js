const chooser = document.getElementById('chooser');
const graph = document.getElementById('graph');

fetch(`./mission.csv`).then(res=>res.text()).then(csv=>{
  let rows = csv.split('\n').reverse().slice(1);
  let data = rows.map(row=>row.split(','));

  plot(data[0][0], true);

  data.forEach(entry=>{
    let opt = document.createElement('option');
    opt.textContent = `${entry[1]} (${entry[2]})`;
    opt.setAttribute('value', entry[0]);
    chooser.appendChild(opt);
  });
});

chooser.onchange = function() {
  plot(chooser.value);
}
//window.setInterval(()=>plot(chooser.value), 5000)

function plot(name, newPlot) {
  fetch(`./${name}`).then(res=>res.text()).then(csv=>{
    let rows = csv.split('\n');
    let data = rows.map(row=>row.split(','));

    let sets = [];
    data[0].forEach((name, index)=>{
      let x = [];
      let y = [];
      data.slice(1).forEach(row=>{
        x.push(row[0]);
        y.push(row[index]);
      });


      sets.push({
        x,
        y,
        name
      });
    });

    console.log(sets);

    let template;
    if (!newPlot) template = Plotly.makeTemplate(graph)
    return Plotly.newPlot( graph, sets.slice(1), {title: 'Telemetry view', template}, {responsive: true} );
  });
}
