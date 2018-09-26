/*
Wing Builder Initalize
*/

<div id="wing-builder" data-share-url="<?php echo esc_url(home_url('/')); ?>">
	<div class="fallback">

	<?php if (is_front_page()): ?>
		<?php
			$link = get_field('hero_link');
			$image = get_field('hero_image');
			$image = ($image['sizes'] && $image['sizes']['large']) ? $image['sizes']['large'] : '';
			$position = get_field('hero_image_position');
		?>
		<section class="home-hero" style="background-image:url('<?php echo $image; ?>'); background-position:<?php echo $position; ?>; background-repeat:no-repeat;">
			<?php echo (!empty($link)) ? '<a href="' . $link . '">' : '<div>'; ?>
				<h2><?php echo widont(get_field('hero_title')); ?></h2>
				<?php
					$items = get_field('hero_items');
					if ($items) {
						echo '<ul>';
						foreach ($items as $item) {
							echo '<li><em>' . $item['name'] . '</em></li>';
						}
						echo '</ul>';
					}
				?>
			<?php echo (!empty($link)) ? '</a>' : '</div>'; ?>
			<i class="icon icon-angle-down"></i>
		</section>
	<?php endif; ?>


	</div>
	<div class="builder">
		<div class="canvas-container">
			<canvas id="wing-builder-canvas"></canvas>
		</div>
		<canvas id="wing-builder-screenshot" width="640" height="480"></canvas>
		<div class="intro">
			<h2><?php echo get_field('wing_builder_intro', 'option'); ?></h2>
			<p><button class="button-orange"><?php echo get_field('wing_builder_button_text', 'option'); ?> <i class="icon icon-wrench"></i></button></p>
		</div>
		<div class="panels">
			<ul id="wing-builder-menu">
				<li><span>Type of Wing</span></li>
				<li><span>Wing Flavor</span></li>
				<li><span>Heat Index</span></li>
				<li><span>Background</span></li>
				<li><span>Share</span></li>
			</ul>
			<ul id="wing-builder-selections">
				<li></li>
				<li></li>
				<li></li>
				<li></li>
			</ul>
			<div class="panel">
				<span class="step-title"><strong>1</strong> Step</span>
				<h2>Choose your Wing Type</h2>
				<p>With 58 flavors and 8 heat indexes, no one has the level of wing personalization we do! <br/>Use our wing builder to design your custom wing. Start by picking bone-in or boneless.</p>
				<ul class="options-wing-types">
					<li><img src="<?php bloginfo('template_directory'); ?>/assets/img/wing-builder/icons/bone-in.png" /><span>Bone In</span></li>
					<li><img src="<?php bloginfo('template_directory'); ?>/assets/img/wing-builder/icons/boneless.png" /><span>Boneless</span></li>
				</ul>
				<button class="button-orange button-next">Next Step <i class="icon icon-angle-right"></i></button>
			</div>
			<div class="panel">
				<span class="step-title"><strong>2</strong> Step</span>
				<h2>Select your Flavor</h2>
				<p>58 flavors ranging from sweet to SAVORY. Try them all, or just explore to find your favorite. <br />Use the top slider to Pick a category, then SELECT a flavor BELOW.</p>
				<div class="slider-group options-flavor-categories">
					<div class="slider-well">
						<div class="slider-container">
							<div><ul class="slider"></ul></div>
						</div>
						<i class="ticker"></i>
						<i class="icon icon-angle-left"></i>
						<i class="icon icon-angle-right"></i>
					</div>
				</div>
				<div class="slider-group options-flavor-items">
					<div class="slider-well">
						<div class="slider-container">
							<div><ul class="slider"></ul></div>
						</div>
						<i class="icon icon-angle-left"></i>
						<i class="icon icon-angle-right"></i>
					</div>
				</div>
				<button class="button-orange button-prev"><i class="icon icon-angle-left"></i> Back</button>
				<button class="button-orange button-next">Next Step <i class="icon icon-angle-right"></i></button>
			</div>
			<div class="panel">
				<span class="step-title"><strong>3</strong> Step</span>
				<h2>Select your Heat</h2>
				<p>No one gives you the kind of precision heat we do. From virgin to insanity — <br />pick the degree that best matches your preference...or limit.</p>
				<div class="slider-group options-flavors">
					<div class="slider-well">
						<div class="slider-container">
							<div><ul class="slider"></ul></div>
						</div>
						<i class="ticker"></i>
						<i class="icon icon-angle-left"></i>
						<i class="icon icon-angle-right"></i>
						<a id="wing-builder-insanity-button" class="button-yellow" href="<?php echo esc_url(home_url('/insanity-wing-challenge')); ?>">Insanity Wing Challenge <i class="icon icon-angle-right"></i></a>
					</div>
				</div>
				<button class="button-orange button-prev"><i class="icon icon-angle-left"></i> Back</button>
				<button class="button-orange button-next">Next Step <i class="icon icon-angle-right"></i></button>
			</div>
			<div class="panel">
				<span class="step-title"><strong>4</strong> Step</span>
				<h2>Select your Background</h2>
				<p>Never before have we seen such a beautiful wing. Your creativity is an inspiration to us all, and should be shared with the world. Pick a background or shoot your own. Share. Then wait for your phone call from the Louvre.</p>
				<div class="slider-group options-backgrounds">
					<div class="slider-well">
						<div class="slider-container">
							<div><ul class="slider"></ul></div>
						</div>
						<i class="ticker"></i>
						<i class="icon icon-angle-left"></i>
						<i class="icon icon-angle-right"></i>
					</div>
				</div>
				<button class="button-orange button-prev"><i class="icon icon-angle-left"></i> Back</button>
				<button class="button-orange button-next">Next Step <i class="icon icon-angle-right"></i></button>
			</div>
			<div class="panel">
				<h2>Share or Download</h2>
				<ul class="share-icons">
					<li><a id="wing-builder-link-twitter" target="_blank"><i class="icon icon-twitter"></i></a></li>
					<li><a id="wing-builder-link-email"><i class="icon icon-envelope"></i></a></li>
					<li id="wing-builder-link-download-item"><a id="wing-builder-link-download"><i class="icon icon-cloud-download"></i></a></li>
				</ul>
				<ul class="share-buttons">
					<li><a class="button-yellow" href="<?php echo esc_url(home_url('/menu')); ?>">Go to Menu <i class="icon icon-angle-right"></i></a>
					<li><button id="wing-builder-link-start-over" class="button-orange">Start Over <i class="icon icon-refresh"></i></button></li>
				</ul>
				<button class="button-orange button-prev"><i class="icon icon-angle-left"></i> Back</button>
			</div>
		</div>
		<div class="loader">
			<div>
				<i class="circle circle-1"></i>
				<i class="circle circle-2"></i>
				<i class="circle circle-3"></i>
				<i class="circle circle-4"></i>
				<i class="circle circle-5"></i>
				<i class="circle circle-6"></i>
				<i class="circle circle-7"></i>
				<i class="circle circle-8"></i>
				<i class="circle circle-9"></i>
				<i class="circle circle-10"></i>
				<i class="circle circle-11"></i>
				<i class="circle circle-12"></i>
			</div>
		</div>
	</div>
	<script class="wing-builder-data" type="application/json"><?php

		// Start
		$json = array(
			'flavor_of_the_month' => '',
			'flavors' => array(),
			'heat_indexes' => array(),
			'backgrounds' => array()
		);

		// Flavor of the Month
		$flavor = get_field('flavor_of_the_month', 'option');
		if ($flavor) {
			$json['flavor_of_the_month'] = $flavor->post_title;
		}

		// Flavors
		$flavorCategories = get_terms('flavor-category', array(
			'hide_empty'	=> TRUE,
			'order'			=> 'ASC',
			'orderby'		=> 'name'
		));
		if (!empty($flavorCategories)) {
			foreach ($flavorCategories as $category) {
				$query = new WP_Query(array(
					'order' => 'ASC',
					'orderby' => 'title',
					'post_type' => 'flavor',
					'taxonomy' => 'flavor-category',
					'term' => $category->slug,
					'showposts' => -1
				));
				if (!empty($query)) {
					$row = array(
						'title' => $category->name,
						'items' => array()
					);
					while ($query->have_posts()) {
						$query->the_post();
						$row['items'][] = array(
							'color' => (get_field('color') != null) ? get_field('color') : '#f68911',
							'normalScale' => (get_field('normal_scale') != null) ? get_field('normal_scale') : 0.5,
							'shininess' => (get_field('shininess') != null) ? get_field('shininess') : 10,
							'texture' => (get_field('texture') != null) ? get_field('texture') : 1,
							'textureAmount' => (get_field('texture_amount') != null) ? get_field('texture_amount') : 0.5,
							'title' => get_the_title()
						);
					}
					wp_reset_postdata();
					$json['flavors'][] = $row;
				}
			}
		}

		// Heat Indexes
		$heatIndexes = get_field('heat_indexes', 'option');
		if (!empty($heatIndexes)) {
			foreach ($heatIndexes as $heat) {
				$json['heat_indexes'][] = array(
					'color' => $heat['color'],
					'title' => $heat['name']
				);
			}
		}

		// Backgrounds
		$backgrounds = get_field('wing_builder_backgrounds', 'option');
		if (!empty($backgrounds)) {
			foreach($backgrounds as $bg) {
				$json['backgrounds'][] = $bg['image'];
			}
		}

		// All Done
		echo json_encode($json);

	?></script>
</div>
