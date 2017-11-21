import { Component, OnInit } from '@angular/core';
import { Service } from '../shared/service';
import { OpenShiftService } from '../shared/openshift.service';

@Component({
  selector: 'cicd-services',
  templateUrl: './cicd-services.component.html',
  styleUrls: ['./cicd-services.component.css']
})
export class CicdServicesComponent implements OnInit {
  cicdservices: Service[];
  tiles = [
    {text: 'One', cols: 1, rows: 1, color: 'lightblue'},
    {text: 'Two', cols: 1, rows: 1, color: 'lightgreen'},
    {text: 'Three', cols: 1, rows: 1, color: 'lightpink'},
    {text: 'Four', cols: 1, rows: 1, color: '#DDBDF1'},
  ];
  constructor(private osservice: OpenShiftService) { }

  ngOnInit() {
    this.getCICDservices();
  }

  getCICDservices(): void {
    this.osservice.getCICDservices().then(services => {
      this.cicdservices = services;
    });
  }


}
