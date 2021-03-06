// Package graphastar defines fzipp.astar.Graph implementations for
// graph.Graph.
package graphastar

import (
	"math"

	"github.com/downflux/game/map/utils"
	"github.com/downflux/game/pathing/hpf/graph"
	"github.com/golang/protobuf/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	tile "github.com/downflux/game/map/map"
	pdpb "github.com/downflux/game/pathing/api/data_go_proto"
	fastar "github.com/fzipp/astar"
)

var (
	notImplemented = status.Error(
		codes.Unimplemented, "function not implemented")
)

// dFunc provides a shim for the graph.Graph neighbor distance
// function.
func dFunc(g *graph.Graph, src, dest fastar.Node) float64 {
	cost, err := graph.D(g, src.(*pdpb.AbstractNode), dest.(*pdpb.AbstractNode))
	if err != nil {
		return math.Inf(0)
	}

	return cost
}

// hFunc provides a shim for the graph.Graph heuristic function.
func hFunc(src, dest fastar.Node) float64 {
	cost, err := graph.H(src.(*pdpb.AbstractNode), dest.(*pdpb.AbstractNode))
	if err != nil {
		return math.Inf(0)
	}

	return cost
}

// graphImpl implements fzipp.astar.Graph for the graph.Graph struct.
type graphImpl struct {
	// g holds information on how different AbstractNode objects are
	// connected via AbstractEdge links.
	g *graph.Graph

	// src and dest are the query filters passed into Path; we cache these
	// to pass auxiliary context to Neighbours.
	src, dest *pdpb.AbstractNode
}

// Neighbours returns neighboring AbstractNode objects from a
// graph.Graph.
//
// Neighbours filters out ephemeral AbstractNode objects, i.e. temporary
// nodes generated by concurrent astar.Path operations which are not
// the source or destination nodes.
func (g graphImpl) Neighbours(n fastar.Node) []fastar.Node {
	neighbors, _ := g.g.Neighbors(n.(*pdpb.AbstractNode))
	var res []fastar.Node
	for _, n := range neighbors {
		if !n.GetIsEphemeral() || proto.Equal(g.src, n) || proto.Equal(g.dest, n) {
			res = append(res, n)
		}
	}
	return res
}

// Path returns pathing information for two AbstractNode objects embedded in a
// graph.Graph. This function returns a (path, cost, error) tuple,
// where path is a list of AbstractNode objects and cost is the actual cost as
// calculated by calling D over the returned path. An empty path indicates
// there is no path found between the two AbstractNode objects.
//
// The input AbstractNode instances are query filters; they do not have to be
// explicitly the same instances which reside in the Graph object.
//
// The returned path object returns a reference to the internal AbstractNode
// instances. They should be treated as read-only objects.
func Path(tm *tile.Map, g *graph.Graph, src, dest utils.MapCoordinate) ([]*pdpb.AbstractNode, float64, error) {
	if tm == nil {
		return nil, 0, status.Error(codes.FailedPrecondition, "cannot have nil tile.Map input")
	}
	if g == nil {
		return nil, 0, status.Error(codes.FailedPrecondition, "cannot have nil graph.Graph input")
	}

	srcNode, err := g.NodeMap.Get(src)
	if err != nil {
		return nil, 0, err
	}
	destNode, err := g.NodeMap.Get(dest)
	if err != nil {
		return nil, 0, err
	}
	if srcNode == nil || destNode == nil {
		return nil, math.Inf(0), nil
	}

	d := func(a, b fastar.Node) float64 {
		return dFunc(g, a, b)
	}
	nodes := fastar.FindPath(graphImpl{
		g:    g,
		src:  proto.Clone(srcNode).(*pdpb.AbstractNode),
		dest: proto.Clone(destNode).(*pdpb.AbstractNode),
	}, srcNode, destNode, d, hFunc)

	var res []*pdpb.AbstractNode
	for _, node := range nodes {
		res = append(res, node.(*pdpb.AbstractNode))
	}

	var cost float64
	if res == nil {
		cost = math.Inf(0)
	} else {
		cost = nodes.Cost(d)
	}
	return res, cost, nil
}
