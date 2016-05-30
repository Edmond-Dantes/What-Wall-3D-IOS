//
//  Maze.swift
//  Roly Moly
//
//  Created by Future on 1/26/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
import QuartzCore



extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i{
                swap(&self[i], &self[j])
            }
        }
    }
}

var mySimpleMazeCalculator = [Int]()

var myMaze:Maze? = nil


class Maze: SCNNode {
    
    var level: Int = 0
    #if os(iOS)
    var levelHeight:Float = 0
    #elseif os(OSX)
    var levelHeight:CGFloat = 0
    #endif
    
    
    var MAZE_ROWS:Int {
        get{
            return (self.level)*2 + 3
        }
    }
    var MAZE_COLUMNS:Int {
        get{
            return self.MAZE_ROWS
        }
    }
    
    var maxMapAreaXValue:CGFloat {
        get{
            return myMazeCellSize.width/2 + CGFloat((MAZE_COLUMNS - 1) + 1) * myMazeCellSize.width
        }
    }
    
    var minMapAreaXValue:CGFloat {
        get{
            return myMazeCellSize.width/2
        }
    }
    
    var maxMapAreaYValue:CGFloat {
        get{
            return myMazeCellSize.height/2 + CGFloat((MAZE_ROWS - 1) + 1) * myMazeCellSize.height
        }
    }
    
    var minMapAreaYValue:CGFloat {
        get{
            return myMazeCellSize.height/2
        }
    }
    
    
    
    var myMazeCellSize:CGSize = CGSize()
    
    
    var mazeNumberMatrix:[Int] = []
    var mazeCellMatrix:[Int:MazeCell] = [:]
    var escapePath:[Int] = []
    private var currentPath:[Int] = []
    var levelExitPathArray:[SmashBlock.blockPosition] = []
    var stageExitsArray:[Int:[SmashBlock.blockPosition]] = [:]
    
    private var visitedCellCount:Int = 0
    private var maxPathCount = 0
    var startPoint = 0
    var exitPoint = 0
    private var currentPoint = 0
    private var deadEndCount = 0
    
    
    override init(){
        super.init()
    }
    
    init(level:CGFloat){
        
        super.init()
        
        print("START")
        self.level = Int(level)
        
        self.mazeNumberMatrix = []
        
        self.myMazeCellSize.width = gameFrame.width/10
        self.myMazeCellSize.height = gameFrame.height/10
        
        
        //------------------------
        //Loading all of the cells
        
        for row in 0 ..< MAZE_ROWS{
            for column in 0 ..< MAZE_COLUMNS{
                
                let gridPoint = column + row * MAZE_COLUMNS
                self.mazeNumberMatrix.insert(0, atIndex: gridPoint)
                
            }
        }
        print("START")
        
        
        findAppropiateMaze()
        
        print("START")
        loadEscapePath()
        loadStageExits()
        loadRealMaze(level)
        
    }
    
    func loadEscapePath(){
        //note: cell matrix has been flipped vertically so math matches x and y coordinates
        //allow only one path
        for currentStage in 0 ..< escapePath.count - 1{
            let nextPathPoint = escapePath[currentStage + 1]
            let pathPoint = escapePath[currentStage]
            self.levelExitPathArray.append(SmashBlock.blockPosition.rightTop)
            if nextPathPoint == pathPoint + 1{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitPathArray[currentStage] = .rightTop
                }else{
                    self.levelExitPathArray[currentStage] = .rightBottom
                }
                
            }else if nextPathPoint == pathPoint - 1{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitPathArray[currentStage] = .leftTop
                }else{
                    self.levelExitPathArray[currentStage] = .leftBottom
                }
                
            }else if nextPathPoint == pathPoint + MAZE_ROWS{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitPathArray[currentStage] = .topRight
                }else{
                    self.levelExitPathArray[currentStage] = .topLeft
                }
                
            }else if nextPathPoint == pathPoint - MAZE_ROWS{
                if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                    self.levelExitPathArray[currentStage] = .bottomRight
                }else{
                    self.levelExitPathArray[currentStage] = .bottomLeft
                }
                
            }else{
                
            }
            
            //insert the correct path / excape path exit into the stages exits array (at the appropriate stages = pathPoint)
            self.stageExitsArray[pathPoint] = [self.levelExitPathArray[currentStage]]//possibleExitsArray
            
        }
    }
    
    func loadStageExits(){
        
        for row in 0 ..< MAZE_ROWS{
            for column in 0 ..< MAZE_COLUMNS{
                
                var verticalExitCounter:Int = 0
                var horizontalExitCounter:Int = 0
                
                
                let gridPoint = column + row * MAZE_COLUMNS
                //let cellType = self.mazeNumberMatrix[gridPoint]
                
                //stageExitsArray
                var possibleExitsArray:[SmashBlock.blockPosition] = []
                
                if column % 2 != 0 && row % 2 != 0 {
                    
                    var escapeExit:SmashBlock.blockPosition? = nil
                    
                    
                    
                    
                    // *******************
                    // the correct path / escape path exit will always be loaded first
                    
                    if self.stageExitsArray[gridPoint] != nil{
                        for exit in self.stageExitsArray[gridPoint]!{
                            escapeExit = exit
                        }
                        possibleExitsArray.append(escapeExit!)
                    }
                    // *******************
                    
                    
                    
                    // ----------------------------------------------
                    //Check here for possible paths through the maze
                    //needs updating and precise conditional statements
                    // ----------------------------------------------
                    
                    //down
                    if row - 2 >= 0 && (self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] != 8 && self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] != 9){
                        if escapeExit == .bottomLeft || escapeExit == .bottomRight{
                            //break
                        }else{
                            if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                                possibleExitsArray.append(.bottomLeft)
                            }else{
                                possibleExitsArray.append(.bottomRight)
                            }
                        }
                        verticalExitCounter += 1
                        
                    }
                    //right
                    if column + 2 <= MAZE_COLUMNS - 1 && (self.mazeNumberMatrix[(column + 1) + row  * MAZE_COLUMNS] != 8 && self.mazeNumberMatrix[(column + 1) + row  * MAZE_COLUMNS] != 9) {
                        if escapeExit == .rightTop || escapeExit == .rightBottom{
                            //break
                        }else{
                            if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                                possibleExitsArray.append(.rightTop)
                            }else{
                                possibleExitsArray.append(.rightBottom)
                            }
                        }
                        horizontalExitCounter += 1
                    }
                    //up
                    if row + 2 <= MAZE_ROWS - 1 && (self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] != 8 && self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] != 9) {
                        if escapeExit == .topLeft || escapeExit == .topRight{
                            //break
                        }else{
                            if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                                possibleExitsArray.append(.topRight)
                            }else{
                                possibleExitsArray.append(.topLeft)
                            }
                        }
                        verticalExitCounter += 1
                    }
                    //left
                    if column - 2 >= 0 && (self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] != 8 && self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] != 9) {
                        if escapeExit == .leftTop || escapeExit == .leftBottom{
                            //break
                        }else{
                            if Int(arc4random_uniform(UInt32(2))) % 2 == 0{
                                possibleExitsArray.append(.leftTop)
                            }else{
                                possibleExitsArray.append(.leftBottom)
                            }
                        }
                        horizontalExitCounter += 1
                    }
                    
                    
                    //insert possible exits into the stages array
                    self.stageExitsArray[gridPoint] = []
                    self.stageExitsArray[gridPoint] = possibleExitsArray
                    
                    //if 2 horizontal exits and no vertical /or vise versa then this is a continuedPath point
                    if horizontalExitCounter >= 2 && verticalExitCounter == 0{
                        self.mazeNumberMatrix[gridPoint] = 11
                    }else if verticalExitCounter >= 2 && horizontalExitCounter == 0{
                        self.mazeNumberMatrix[gridPoint] = 10
                    }
                    
                }
                
                
                
                
                
            }
        }
        
    }
    
    func levelPathColored(){
    
        for i in 1 ..< escapePath.count - 1{
            let cell = self.mazeCellMatrix[escapePath[i]]
            #if os(iOS)
            cell!.color = UIColor(colorLiteralRed: Float(i)/Float(escapePath.count - 1), green: Float(0), blue: Float((escapePath.count - 1)-i)/Float(escapePath.count - 1), alpha: Float(1)) as! Color
            #elseif os(OSX)
            cell!.color = NSColor(calibratedRed: CGFloat(i)/CGFloat(escapePath.count - 1), green: CGFloat(0), blue: CGFloat((escapePath.count - 1)-i)/CGFloat(escapePath.count - 1), alpha: CGFloat(1))
            #endif
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func findAppropiateMaze(){
        var row = 0
        var column = 0
        
        
        repeat{
            
            for row in 0 ..< MAZE_ROWS{
                for column in 0 ..< MAZE_COLUMNS{
                    
                    let gridPoint = column + row * MAZE_COLUMNS
                    self.mazeNumberMatrix[gridPoint] = 0
                    
                }
            }
            hasCorrectEscapePath = false
            visitedCellCount = 0
            maxPathCount = 0
            exitPoint = 0
            deadEndCount = 0
            self.escapePath = []
            self.currentPath = []
            print("start randomMazeGrid")
            (column, row) = randomMazeGridPosition()
            print("start generateMazeRecursion")
            generateMazeRecursion(column: column, row: row)
            self.mazeNumberMatrix[exitPoint] = 4  //exit point
            print("finish generateMazeRecursion")
            print("path count = \(self.escapePath.count)")
        }while !hasCorrectEscapePath
        
        //allow only one path
        for pathPoint in escapePath{
            if self.mazeNumberMatrix[pathPoint] == 1 || self.mazeNumberMatrix[pathPoint] == 8{
                self.mazeNumberMatrix[pathPoint] = 5
            }
            
        }
        
        
        
        
    }
    
    func loadRealMaze(level:CGFloat){
        
        //note: cell matrix is flipped vertically so math matches x and y coordinates
        
        for row in 0 ..< MAZE_ROWS{
            for column in 0 ..< MAZE_COLUMNS{
                
                let gridPoint = column + row * MAZE_COLUMNS
                let cellType = self.mazeNumberMatrix[gridPoint]
                
                //if row % 2 != 0 && column % 2 != 0 || cellType == 0 {
                
                #if os(OSX)
                let colCalcX = myMazeCellSize.width/2 + CGFloat((column - 1) + 1) * myMazeCellSize.width
                let rowCalcY = myMazeCellSize.height/2 + CGFloat((row - 1) + 1) * myMazeCellSize.height
                #elseif os(iOS)
                let colCalcX = Float(myMazeCellSize.width)/2 + Float((column - 1) + 1) * Float(myMazeCellSize.width)
                let rowCalcY = Float(myMazeCellSize.height)/2 + Float((row - 1) + 1) * Float(myMazeCellSize.height)
                #endif
                var sizeCalc = myMazeCellSize
                
                
                if column % 2 == 0 {
                    if cellType == 8 || cellType == 9 || cellType == 0{//barrier
                        sizeCalc.width = 1
                        sizeCalc.height += sizeCalc.height + 1
                    }else{
                        sizeCalc.height = 1
                        
                    }
                    
                    
                }
                if row % 2 == 0 {
                    if cellType == 8 || cellType == 9 || cellType == 0{//barrier
                        sizeCalc.height = 1
                        sizeCalc.width += sizeCalc.width + 1
                    }else{
                        sizeCalc.width = 1
                        
                    }
                    
                }
                
                if row % 2 == 0 && column % 2 == 0{
                    if cellType == 8 || cellType == 9 || cellType == 0{//barrier
                        sizeCalc.height = 1
                        sizeCalc.width = 1
                    }
                }
                
                if cellType == 10{
                    sizeCalc.width = 1
                }else if cellType == 11{
                    sizeCalc.height = 1
                }
                
                let cell = MazeCell(gridPoint: gridPoint, size: sizeCalc)
                cell.position = SCNVector3(x: colCalcX, y: rowCalcY, z: levelHeight)
                
                
                self.mazeCellMatrix[gridPoint] = cell
                
                switch cellType{
                case 1:  // visited
                    cell.color = Color.blueColor()
                    cell.visited = true
                case 2:  // start point
                    cell.color = Color.blueColor()
                    cell.visited = true
                    self.startPoint = gridPoint
                    self.currentPoint = self.startPoint
                    
                case 3:  // deadends
                    cell.color = Color.grayColor()
                    cell.visited = true
                    
                case 4:  // exit point
                    cell.color = Color.redColor()
                    cell.visited = true
                    
                case 5: //escape path
                    cell.visited = true
                    cell.alpha = 1
                    cell.color = Color.whiteColor()
                    
                case 6: //coverted to holes
                    cell.color = Color.clearColor()
                    cell.visited = true
                case 7://inbetween path points
                    cell.color = Color.whiteColor()
                    cell.visited = true
                case 8: // barriers
                    cell.color = Color.yellowColor()
                case 9: //surrounding barriers
                    cell.color = Color.brownColor()
                case 10: //continued Path point vertical
                    cell.color = Color.orangeColor()
                case 11: //continued Path point horizontal
                    cell.color = Color.orangeColor()
                default: // barriers = 0
                    cell.color = Color.yellowColor()
                    
                    
                    
                    
                    
                }
               
                self.addChildNode(cell)
                
            
                
            }
            
            
            
        }
        
        print("MAZE = \(MAZE_COLUMNS) X \(MAZE_ROWS)")
    }
    
    func randomMazeGridPosition()->(Int,Int){
        
        //insert random starting point logic
        
        var row = 0
        var column = 0
        
        while row % 2 == 0{
            row = Int(arc4random_uniform(UInt32(MAZE_ROWS)))
        }
        while column % 2 == 0{
            column = Int(arc4random_uniform(UInt32(MAZE_COLUMNS)))
        }
        
        
        
        
        return (column, row)
        
    }
    
    func randomDirections()->[MazeCell.wallLocations]{
        
        //add logic
        var myRandomOrderedMazeDirections:[MazeCell.wallLocations] = [ .up, .down, .left, .right ]
        myRandomOrderedMazeDirections.shuffle()
        return myRandomOrderedMazeDirections
        
    }

    var hasCorrectEscapePath:Bool = false
    
    var minEscapePathCount:Int {
        get{
            
            return self.level * 2 + 1
            
            
            
        }
    }
    var maxEscapePathCount:Int {
        get{
            if self.level >= 10{
                return MAZE_COLUMNS * self.level / 2
            }else if self.level >= 5{
                return MAZE_COLUMNS * self.level * 2 / 3
            }else if self.level > 1{
                return MAZE_COLUMNS * self.level
            }
            return 7
        }
    }
    
    func generateMazeRecursion(column column:Int, row:Int){
        
        
        visitedCellCount += 1
        
        //-----Keep track of currectPath
        self.currentPath.append(column + row * MAZE_COLUMNS)
        
        
        self.mazeNumberMatrix[column + (row) * MAZE_COLUMNS] = 1 //visited general
        
        if self.visitedCellCount == 1{
            self.mazeNumberMatrix[column + (row) * MAZE_COLUMNS] = 2 //start and visited
        }
        
        
        let cellWalls = randomDirections()
        var deadEnd = true
        for direction in cellWalls{
            
            switch direction{
            case .up:
                if row - 2 <= 0{
                    continue
                }
                if self.mazeNumberMatrix[column + (row - 2) * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] = 7
                    self.currentPath.append((column ) + (row - 1) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column, row: row - 2)
                    self.currentPath.removeLast()
                    
                }else{
                    if self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] != 7{
                        self.mazeNumberMatrix[column + (row - 1) * MAZE_COLUMNS] = 8
                    }
                }
                
            case .right:
                if column + 2 >= MAZE_COLUMNS - 1{
                    continue
                }
                if self.mazeNumberMatrix[(column + 2) + row  * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[(column + 1) + row * MAZE_COLUMNS] = 7
                    self.currentPath.append((column + 1 ) + (row ) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column + 2, row: row )
                    self.currentPath.removeLast()
                    
                }else{
                    if self.mazeNumberMatrix[(column + 1) + row * MAZE_COLUMNS] != 7{
                        self.mazeNumberMatrix[(column + 1) + row * MAZE_COLUMNS] = 8
                    }
                }
            case .down:
                if row + 2 >= MAZE_ROWS - 1{
                    continue
                }
                if self.mazeNumberMatrix[column + (row + 2) * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] = 7
                    
                    self.currentPath.append((column ) + (row + 1) * MAZE_COLUMNS)
                    generateMazeRecursion(column: column, row: row + 2)
                    self.currentPath.removeLast()
                    
                }else{
                    if self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] != 7{
                        self.mazeNumberMatrix[column + (row + 1) * MAZE_COLUMNS] = 8
                    }
                }
                
            case .left:
                if column - 2 <= 0{
                    continue
                }
                if self.mazeNumberMatrix[(column - 2) + row  * MAZE_COLUMNS] == 0 {
                    deadEnd = false
                    self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] = 7
                    
                    self.currentPath.append((column - 1) + row * MAZE_COLUMNS)
                    generateMazeRecursion(column: column - 2, row: row )
                    self.currentPath.removeLast()
                }else{
                    if self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] != 7{
                        self.mazeNumberMatrix[(column - 1) + row * MAZE_COLUMNS] = 8
                    }
                }
                
            }
            
        }
        if deadEnd{
            
            deadEndCount += 1
            self.mazeNumberMatrix[column + row * MAZE_COLUMNS] = 3 //deadend cell and visited
            
            if maxPathCount < visitedCellCount{
                hasCorrectEscapePath = false
                
                maxPathCount = visitedCellCount
                
                //---record longest path
                self.escapePath = self.currentPath
                
                exitPoint = column + row * MAZE_COLUMNS
                if maxPathCount >= minEscapePathCount && maxPathCount <= maxEscapePathCount{
                    hasCorrectEscapePath = true
                }
            }

            
        }
        visitedCellCount -= 1
        //Pop currentPath when changing to new path
        self.currentPath.removeLast()
        
    }
    
    
    
    
}