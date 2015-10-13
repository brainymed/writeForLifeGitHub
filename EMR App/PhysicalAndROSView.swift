//  PhysicalAndROSView.swift
//  EMR App
//  Created by Arnav Pondicherry  on 9/14/15.
//  Copyright © 2015 Confluent Ideals. All rights reserved.

// This is a struct, NOT a view - its purpose is to assign the correct image (L) (including the buttons & rotation item) & view (R) for the dataEntryImageView.
// Upon rotation, we want to - swap the image, hide certain buttons & reveal others, & reposition the rotation button from one side to the other. We will layer all of the buttons on the view & selectively hide them.

import UIKit

struct PhysicalAndROSView {
    
    let index: Int //assign unique index to each image (used for swapping the image)
    let viewChoice: String //check if the input view is physical or ROS
    let gender: Int //check if the currentPatient is male or female, 0 = male & 1 = female
    let childOrAdult: Int //check if patient is child or adult, 0 = adult & 1 = child
    var imageName: String
    let imageFile: UIImage //converts file name -> image
    var rotation: Bool //checks if rotation has occurred
    
    init(viewChoice: String, gender: Int, childOrAdult: Int) {
        self.viewChoice = viewChoice
        self.gender = gender
        self.childOrAdult = childOrAdult
        self.rotation = false
        
        if self.childOrAdult == 1 { //Patient is an adult
            if self.gender == 0 { //Male adult {1}
                self.index = 1
                self.imageName = "adult_male_outline_front.png"
            } else { //Female adult {2}
                self.index = 2
                self.imageName = "adult_female_outline_front.png"
            }
        } else { //Patient is a child
            if self.gender == 0 { //Male child {3}
                self.index = 3
                self.imageName = "child_male_outline_front.png"
            } else { //Female child {4}
                self.index = 4
                self.imageName = "child_female_outline_front.png"
            }
        }
        self.imageFile = UIImage(named: self.imageName)!
    }
    
    func getOriginalImageFile() -> UIImage { //Returns the image file based on user input & currentPatient
        return imageFile
    }
    
    mutating func getRotatedImageFile() -> UIImage { //Checks current rotation status & returns the opposite image for the set
        var newImageName = String()
        if self.rotation == false { //Rotation from front -> back
            self.rotation = true
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_back.png"
            case 2:
                newImageName = "adult_female_outline_back.png"
            case 3:
                newImageName = "child_male_outline_back.png"
            case 4:
                newImageName = "child_female_outline_back.png"
            default: //This case should never be triggered!
                newImageName = ""
            }
        } else { //Rotation from back -> front
            self.rotation = false
            switch self.index {
            case 1:
                newImageName = "adult_male_outline_front.png"
            case 2:
                newImageName = "adult_female_outline_front.png"
            case 3:
                newImageName = "child_male_outline_front.png"
            case 4:
                newImageName = "child_female_outline_front.png"
            default: //This case should never be triggered!
                newImageName = ""
            }
        }
        return UIImage(named: newImageName)!
    }
}