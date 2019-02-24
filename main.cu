#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <iostream>

const unsigned int WIDTH = 800;
const unsigned int HEIGHT = 600;
const float DEPTH = -700.0f; // for sound
const std::string WINDOW_TITLE = "Moon, Earth, Sun, Spaghetti Way!";

int main(int argc, char** argv[])
{
	sf::RenderWindow window(sf::VideoMode(WIDTH, HEIGHT), WINDOW_TITLE);
	window.setFramerateLimit(60);

	// Load background
	sf::Texture spaceTexture;
	spaceTexture.loadFromFile("stars.png");
	sf::Sprite background(spaceTexture);
	float textureWidth = spaceTexture.getSize().x;
	float textureHeight = spaceTexture.getSize().y;
	background.setScale(WIDTH / textureWidth, HEIGHT / textureHeight);

	// Load Sun
	sf::Texture sunTexture;
	sunTexture.loadFromFile("sun2.png");
	sf::Sprite sun(sunTexture);
	sun.setOrigin(sunTexture.getSize().x / 2, sunTexture.getSize().y / 2);
	sun.setScale(0.4f, 0.4f);
	sun.setPosition(WIDTH / 2, HEIGHT / 2);

	// Load Earth
	sf::Texture earthTexture;
	earthTexture.loadFromFile("earth3.png");
	sf::Sprite earth(earthTexture);
	earth.setOrigin(earthTexture.getSize().x / 2, earthTexture.getSize().y / 2);
	earth.setScale(0.1f, 0.1f);

	// Load Moon
	sf::Texture moonTexture;
	moonTexture.loadFromFile("moon1.png");
	sf::Sprite moon(moonTexture);
	moon.setOrigin(moonTexture.getSize().x / 2, moonTexture.getSize().y / 2);
	moon.setScale(0.01f, 0.01f);

	// Load earth sound
	sf::SoundBuffer buffer;
	buffer.loadFromFile("earthsound.wav");
	sf::Sound sound(buffer);
	sound.setPosition(WIDTH/2, HEIGHT/2, DEPTH/2);
	sound.play();
	sound.setLoop(true);
	sound.setRelativeToListener(false);
	sound.setMinDistance(50.0f);
	sound.setAttenuation(2.0);
	sf::Vector3f soundPosition(earth.getPosition().x, earth.getPosition().y, DEPTH / 2);

	// Load listener
	sf::Listener::setPosition(WIDTH/2, HEIGHT/2, -50.0f);
	sf::Listener::setDirection(0.0f, 0.0f, -1.0f);
	sf::Listener::setGlobalVolume(100.0f);

	float earthAngle = 3.0f;
	float moonAngle = 3.0f;

	while (window.isOpen())
	{
		sf::Event event;
		while (window.pollEvent(event))
		{
			if (event.type == sf::Event::Closed)
			{
				window.close();
			}
			if (event.key.code == sf::Keyboard::F11)
			{
				window.create(sf::VideoMode(WIDTH, HEIGHT),
					WINDOW_TITLE, sf::Style::Fullscreen);
				window.setFramerateLimit(60);
			}
			if (event.key.code == sf::Keyboard::Escape)
			{
				window.create(sf::VideoMode(WIDTH, HEIGHT),
					WINDOW_TITLE);
				window.setFramerateLimit(60);
			}
		}

		// Update angles of Earth and moon
		earthAngle += 0.004f;
		moonAngle -= 0.019f;
		// Update Earth position
		sf::Vector2f earthDelta(300 * cos(earthAngle), 100 * sin(earthAngle));
		earth.setPosition(sun.getPosition() + earthDelta);
		soundPosition.x = earth.getPosition().x;
		soundPosition.y = earth.getPosition().y;
		// Update Moon position
		float moonDistance = earth.getScale().x*500;
		sf::Vector2f moonDelta(moonDistance * cos(moonAngle), moonDistance * sin(moonAngle));
		moon.setPosition(earth.getPosition() + moonDelta);
		// Update Earth and moon sizes
		float fractionDown = 0.9990f;
		float fractionUp = 1.0010f;
		float fractionSound = 0.5000f;
		if (earth.getPosition().x > sun.getPosition().x)
		{
			earth.scale(fractionUp, fractionUp);
			moon.scale(fractionUp, fractionUp);
			soundPosition.z += fractionSound;
		}
		if (soundPosition.z < DEPTH)
			soundPosition.z = DEPTH;
		else if (earth.getPosition().x < sun.getPosition().x)
		{
			earth.scale(fractionDown, fractionDown);
			moon.scale(fractionDown, fractionDown);
			soundPosition.z -= fractionSound;
		}
		if (soundPosition.z > 0.0f)
			soundPosition.z = 0.0f;		
		sound.setPosition(soundPosition);

		window.clear();
		window.draw(background);

		if (earth.getPosition().y > sun.getPosition().y) // earth is close to view
		{
			window.draw(sun);
			window.draw(earth);
			window.draw(moon);
		}
		else
		{
			window.draw(earth);
			window.draw(moon);
			window.draw(sun);
		}

		window.display();
	}
}
