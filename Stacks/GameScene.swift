//
//  GameScene.swift
//  Stacks
//
//  Created by Henry Calderon on 6/25/20.
//  Copyright © 2020 Henry Calderon. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Obstacle: UInt32 = 0b10
    static let PlayerBody: UInt32 = 0b100
    static let Barrier: UInt32 = 0b1000
}


class GameScene: SKScene {
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 200
    var scrollNode: SKNode!
    var player: Player!
    var obstacleSpawner: ObstacleSpawner!
    var playButton: CustomButtonNode!
    var frontBarrier: SKSpriteNode!
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        /* Set reference to scroll Node */
        if let scrollNode = self.childNode(withName: "scrollNode") {
            self.scrollNode = scrollNode
        } else {
            print("ScrollNode could not be connected properly")
        }
        
        // referecing the barrier node from the scene
        if let frontBarrier = self.childNode(withName: "frontBarrier") as? SKSpriteNode {
            self.frontBarrier = frontBarrier
        } else {
            print("frontBarrier could not be connected properly")
        }
        
        // setting the barrier physics body preferences
        frontBarrier.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
        frontBarrier.physicsBody?.collisionBitMask = PhysicsCategory.None
        frontBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        
        if let playButton = self.childNode(withName: "playButton") as? CustomButtonNode {
            self.playButton = playButton
        } else {
            print("playButton was not initialized properly")
        }
        
        if let spawner = self.childNode(withName: "obstacleSpawner") as? ObstacleSpawner {
          self.obstacleSpawner = spawner
        } else {
          print("spawner could not be connected properly")
        }
        
        if let player = self.childNode(withName: "player") as? Player {
            self.player = player
            print(self.player)
        } else {
            print("player was not initialized properly")
        }
//        print(self.player!)
        player.setup()

    }
    
//    override func didMove(to view: SKView) {
//
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // ray that detects other nodes above the player
        let nodeCheck = physicsWorld.body(alongRayStart: player.position, end: CGPoint(x: player.position.x, y: player.position.y + 100))
        if nodeCheck?.node == nil {
            player.stack(scene: scene!)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        super.update(currentTime)
        /* Process world scrolling */
        scrollWorld()
        obstacleSpawner.generate(scene: self.scene!)

    }
    
    //MARK: Scroll World
    func scrollWorld() {
        /* Scroll World */
        scrollNode.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollNode.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollNode.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollNode)
            }
        }
    }

}
